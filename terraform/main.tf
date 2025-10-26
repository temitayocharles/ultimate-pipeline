terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_config.region
}

# Data source to get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Data source to get subnets in the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Get the first available subnet
data "aws_subnet" "selected" {
  id = data.aws_subnets.default.ids[0]
}

# Jenkins Server (Combined with K8s Master based on PDF diagram)
resource "aws_instance" "jenkins_k8s_master" {
  ami           = var.ami_config.id
  instance_type = var.instance_types.master
  key_name      = var.ssh_config.key_name
  subnet_id     = data.aws_subnet.selected.id
  vpc_security_group_ids = [
    aws_security_group.jenkins_sg.id,
    aws_security_group.k8s_master_sg.id
  ]

  iam_instance_profile = var.iam_config.enable_instance_profiles ? aws_iam_instance_profile.jenkins_k8s_master[0].name : null

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  user_data = file("${path.module}/scripts/jenkins-k8s-master-setup.sh")

  tags = {
    Name        = "${var.project_config.name}-jenkins-k8s-master"
    Project     = var.project_config.name
    Environment = var.project_config.environment
    Role        = "Jenkins-K8s-Master"
  }
}

# Kubernetes Worker Node 1
resource "aws_instance" "k8s_worker_1" {
  ami                    = var.ami_config.id
  instance_type          = var.instance_types.worker
  key_name               = var.ssh_config.key_name
  subnet_id              = data.aws_subnet.selected.id
  vpc_security_group_ids = [aws_security_group.k8s_worker_sg.id]

  iam_instance_profile = var.iam_config.enable_instance_profiles ? aws_iam_instance_profile.k8s_worker[0].name : null

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              ${file("${path.module}/scripts/k8s-worker-setup.sh")}
              sudo hostnamectl set-hostname k8s-worker-1
              EOF

  tags = {
    Name        = "${var.project_config.name}-k8s-worker-1"
    Project     = var.project_config.name
    Environment = var.project_config.environment
    Role        = "K8s-Worker"
  }
}

# Kubernetes Worker Node 2
resource "aws_instance" "k8s_worker_2" {
  count                  = var.feature_flags.enable_worker_2 ? 1 : 0
  ami                    = var.ami_config.id
  instance_type          = var.instance_types.worker
  key_name               = var.ssh_config.key_name
  subnet_id              = data.aws_subnet.selected.id
  vpc_security_group_ids = [aws_security_group.k8s_worker_sg.id]

  iam_instance_profile = var.iam_config.enable_instance_profiles ? aws_iam_instance_profile.k8s_worker[0].name : null

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = <<-EOF
              #!/bin/bash
              ${file("${path.module}/scripts/k8s-worker-setup.sh")}
              sudo hostnamectl set-hostname k8s-worker-2
              EOF

  tags = {
    Name        = "${var.project_config.name}-k8s-worker-2"
    Project     = var.project_config.name
    Environment = var.project_config.environment
    Role        = "K8s-Worker"
  }
}

# Nexus and SonarQube Server
resource "aws_instance" "nexus_sonarqube" {
  count                  = var.feature_flags.enable_tools_instance ? 1 : 0
  ami                    = var.ami_config.id
  instance_type          = var.instance_types.master
  key_name               = var.ssh_config.key_name
  subnet_id              = data.aws_subnet.selected.id
  vpc_security_group_ids = [aws_security_group.tools_sg.id]

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  user_data = file("${path.module}/scripts/nexus-sonarqube-setup.sh")

  tags = {
    Name        = "${var.project_config.name}-nexus-sonarqube"
    Project     = var.project_config.name
    Environment = var.project_config.environment
    Role        = "Tools-Server"
  }
}

# Monitoring Server (Prometheus & Grafana)
resource "aws_instance" "monitoring" {
  count                  = var.feature_flags.enable_monitoring_instance ? 1 : 0
  ami                    = var.ami_config.id
  instance_type          = var.instance_types.monitoring
  key_name               = var.ssh_config.key_name
  subnet_id              = data.aws_subnet.selected.id
  vpc_security_group_ids = [aws_security_group.monitoring_sg.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  user_data = file("${path.module}/scripts/monitoring-setup.sh")

  tags = {
    Name        = "${var.project_config.name}-monitoring"
    Project     = var.project_config.name
    Environment = var.project_config.environment
    Role        = "Monitoring"
  }
}