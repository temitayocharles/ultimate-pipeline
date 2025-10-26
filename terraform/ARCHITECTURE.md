# Architecture Overview

## Service Discovery with AWS Cloud Map

All EC2 instances are automatically registered in AWS Cloud Map, creating DNS-based service discovery. Services can communicate using friendly DNS names instead of hard-coded IP addresses.

**Benefits:**
- No need to update configurations when IPs change
- Automatic service registration
- Health checking integration
- Works seamlessly across the VPC

**DNS Endpoints (accessible within VPC):**
```
jenkins-k8s-master.ultimate-cicd-devops.local
k8s-worker-1.ultimate-cicd-devops.local
k8s-worker-2.ultimate-cicd-devops.local (if enabled)
tools.ultimate-cicd-devops.local (Nexus/SonarQube - if enabled)
monitoring.ultimate-cicd-devops.local (Prometheus/Grafana - if enabled)
```

**Example Usage:**
- Prometheus can scrape metrics from: `http://jenkins-k8s-master.ultimate-cicd-devops.local:9100/metrics`
- Jenkins can access Nexus at: `http://tools.ultimate-cicd-devops.local:8081`
- No need to update when instances are recreated

## OIDC Authentication (No Secrets!)

GitHub Actions can authenticate to AWS without storing AWS credentials using OpenID Connect (OIDC).

**How it works:**
1. GitHub Actions generates a temporary token when workflow runs
2. AWS verifies the token is from your GitHub repo
3. AWS grants temporary credentials (valid ~1 hour)
4. Workflow can access AWS services (ECR, EC2, etc.)

**Benefits:**
- No AWS access keys in GitHub secrets
- Temporary credentials (auto-expire)
- Fine-grained permissions per workflow
- Audit trail of which GitHub workflow accessed what

**Setup:**
1. Set `oidc_config.enable_github_oidc = true` in terraform.auto.tfvars
2. Update `github_org` and `github_repo` with your values
3. Run `terraform apply`
4. Get role ARN: `terraform output github_actions_role_arn`
5. Add to GitHub secrets as `AWS_ROLE_ARN`
6. Use in workflows (see `.github-workflow-example.yml`)

## IAM Instance Profiles

EC2 instances have IAM roles attached, allowing them to access AWS services without credentials.

**Capabilities:**
- **Jenkins/K8s Master:**
  - Push/pull from ECR (Elastic Container Registry)
  - SSM Session Manager (no SSH key needed)
  - EC2 instance metadata access
  
- **K8s Workers:**
  - Pull from ECR (for container images)
  - SSM Session Manager
  
**Benefits:**
- No AWS credentials stored on instances
- Automatic credential rotation
- Easy permission management
- Secure access to AWS services

## Variable Structure

All variables are object-typed for better organization:

```hcl
aws_config = {
  region = "us-east-1"
}

ssh_config = {
  key_name     = "your-key"
  allowed_cidr = ["your-ip/32"]
}

instance_types = {
  master     = "t3.medium"
  worker     = "t3.medium"
  monitoring = "t3.medium"
}

project_config = {
  name        = "your-project"
  environment = "dev"
}

feature_flags = {
  enable_monitoring_instance = true
  enable_tools_instance      = true
  enable_worker_2            = true
}

oidc_config = {
  github_org         = "your-org"
  github_repo        = "your-repo"
  enable_github_oidc = true
}

iam_config = {
  enable_instance_profiles = true
}
```

## Cost Optimization Strategy

**Minimum Setup (~$50/month):**
```hcl
feature_flags = {
  enable_monitoring_instance = false
  enable_tools_instance      = false
  enable_worker_2            = false
}
```

**Development Setup (~$125/month):**
```hcl
feature_flags = {
  enable_monitoring_instance = true
  enable_tools_instance      = true
  enable_worker_2            = false
}
```

**Full Production Setup (~$200-250/month):**
```hcl
feature_flags = {
  enable_monitoring_instance = true
  enable_tools_instance      = true
  enable_worker_2            = true
}
```

**Additional Savings:**
- Stop instances when not in use
- Use AWS Instance Scheduler
- Consider Spot instances for workers (requires code changes)
- Use smaller instance types for testing (t3.small = ~$15/month)
