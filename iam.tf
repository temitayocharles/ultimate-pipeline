# IAM Roles and OIDC Provider for GitHub Actions
# Enables passwordless authentication from GitHub Actions to AWS

# GitHub OIDC Provider
resource "aws_iam_openid_connect_provider" "github" {
  count = var.oidc_config.enable_github_oidc ? 1 : 0

  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = {
    Name        = "${var.project_config.name}-github-oidc"
    Project     = var.project_config.name
    Environment = var.project_config.environment
  }
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  count = var.oidc_config.enable_github_oidc ? 1 : 0

  name = "${var.project_config.name}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github[0].arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.oidc_config.github_org}/${var.oidc_config.github_repo}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_config.name}-github-actions-role"
    Project     = var.project_config.name
    Environment = var.project_config.environment
  }
}

# Policy for GitHub Actions - EC2 and related permissions
resource "aws_iam_role_policy" "github_actions_ec2" {
  count = var.oidc_config.enable_github_oidc ? 1 : 0

  name = "ec2-deployment-policy"
  role = aws_iam_role.github_actions[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:Get*",
          "ec2:List*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:SendCommand",
          "ssm:GetCommandInvocation",
          "ssm:DescribeInstanceInformation"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Instance Profile for Jenkins/K8s Master
resource "aws_iam_role" "jenkins_k8s_master" {
  count = var.iam_config.enable_instance_profiles ? 1 : 0

  name = "${var.project_config.name}-jenkins-k8s-master-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_config.name}-jenkins-k8s-master-role"
    Project     = var.project_config.name
    Environment = var.project_config.environment
  }
}

resource "aws_iam_role_policy_attachment" "jenkins_ssm" {
  count = var.iam_config.enable_instance_profiles ? 1 : 0

  role       = aws_iam_role.jenkins_k8s_master[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "jenkins_ecr" {
  count = var.iam_config.enable_instance_profiles ? 1 : 0

  name = "ecr-access"
  role = aws_iam_role.jenkins_k8s_master[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "jenkins_k8s_master" {
  count = var.iam_config.enable_instance_profiles ? 1 : 0

  name = "${var.project_config.name}-jenkins-k8s-master-profile"
  role = aws_iam_role.jenkins_k8s_master[0].name

  tags = {
    Name        = "${var.project_config.name}-jenkins-k8s-master-profile"
    Project     = var.project_config.name
    Environment = var.project_config.environment
  }
}

# IAM Role for Worker Nodes
resource "aws_iam_role" "k8s_worker" {
  count = var.iam_config.enable_instance_profiles ? 1 : 0

  name = "${var.project_config.name}-k8s-worker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_config.name}-k8s-worker-role"
    Project     = var.project_config.name
    Environment = var.project_config.environment
  }
}

resource "aws_iam_role_policy_attachment" "k8s_worker_ssm" {
  count = var.iam_config.enable_instance_profiles ? 1 : 0

  role       = aws_iam_role.k8s_worker[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "k8s_worker_ecr" {
  count = var.iam_config.enable_instance_profiles ? 1 : 0

  name = "ecr-pull-access"
  role = aws_iam_role.k8s_worker[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "k8s_worker" {
  count = var.iam_config.enable_instance_profiles ? 1 : 0

  name = "${var.project_config.name}-k8s-worker-profile"
  role = aws_iam_role.k8s_worker[0].name

  tags = {
    Name        = "${var.project_config.name}-k8s-worker-profile"
    Project     = var.project_config.name
    Environment = var.project_config.environment
  }
}
