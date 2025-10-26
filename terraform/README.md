# Terraform Infrastructure for Ultimate CI/CD Pipeline

This directory contains Terraform configuration for deploying a complete CI/CD infrastructure on AWS.

## Directory Structure

```
terraform/
├── main.tf                    # EC2 instance definitions
├── variables.tf               # Variable definitions (no defaults)
├── terraform.auto.tfvars      # Configuration values
├── sg.tf                      # Security group rules
├── iam.tf                     # IAM roles, OIDC provider, instance profiles
├── service-discovery.tf       # AWS Cloud Map service discovery
├── outputs.tf                 # Output values
├── backend.tf                 # Remote state configuration (commented)
├── variables-oidc.tf          # OIDC-specific variables
├── ARCHITECTURE.md            # Architecture deep dive
├── QUICKREF.md                # Quick reference commands
└── scripts/                   # Installation scripts
    ├── jenkins-k8s-master-setup.sh
    ├── k8s-worker-setup.sh
    ├── nexus-sonarqube-setup.sh
    └── monitoring-setup.sh
```

## Quick Start

### 1. Prerequisites

- AWS CLI configured with credentials
- Terraform >= 1.0 installed
- SSH key pair created in AWS EC2 console
- SSH key file (`.pem`) in parent directory

### 2. Configure Variables

Edit `terraform.auto.tfvars`:

```hcl
ssh_config = {
  key_name     = "k8s-pipeline-key"  # Your AWS key pair name
  allowed_cidr = ["YOUR_IP/32"]      # Your IP address
}

oidc_config = {
  github_org  = "your-username"      # Your GitHub username
  github_repo = "your-repo"          # Your repository
}
```

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 4. Access Outputs

```bash
terraform output
```

## Infrastructure Components

### EC2 Instances

| Instance | Purpose | Type | Features |
|----------|---------|------|----------|
| Jenkins + K8s Master | CI/CD + K8s control plane | t3.medium | Combined for cost savings |
| K8s Worker 1 | K8s workload node | t3.medium | Always created |
| K8s Worker 2 | K8s workload node | t3.medium | Optional (feature flag) |
| Nexus + SonarQube | Artifact repo + code analysis | t3.medium | Optional (feature flag) |
| Monitoring | Prometheus + Grafana | t3.medium | Optional (feature flag) |

### AWS Services

- **EC2** - Compute instances
- **VPC** - Default VPC (can be customized)
- **Security Groups** - Firewall rules
- **AWS Cloud Map** - Service discovery
- **IAM** - OIDC provider, roles, instance profiles

## Security Features

### OIDC Authentication

Enables GitHub Actions to authenticate with AWS without storing credentials:

```yaml
# .github/workflows/deploy.yml
- uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: us-east-1
```

### IAM Instance Profiles

EC2 instances have IAM roles with permissions for:
- AWS ECR (pull container images)
- AWS Systems Manager (remote management)
- CloudWatch Logs (centralized logging)

### Security Groups

- SSH: Only from specified CIDR
- HTTP: Jenkins (8080), Nexus (8081), SonarQube (9000)
- Monitoring: Prometheus (9090), Grafana (3000)
- Kubernetes: API server (6443), node communication

## Service Discovery

AWS Cloud Map provides DNS-based service discovery:

```bash
# Internal DNS names (accessible from any EC2 instance)
jenkins-k8s-master.ultimate-cicd-devops.local
nexus-sonarqube.ultimate-cicd-devops.local
k8s-worker-1.ultimate-cicd-devops.local
monitoring.ultimate-cicd-devops.local
```

**Benefits:**
- No hardcoded IPs
- Automatic DNS updates
- Works across VPC

## Cost Optimization

### Feature Flags

Control which instances to create:

```hcl
feature_flags = {
  enable_monitoring_instance = false  # Save ~$50/month
  enable_tools_instance      = false  # Save ~$50/month
  enable_worker_2            = false  # Save ~$50/month
}
```

### Cost Estimates (us-east-1)

| Configuration | Instances | Monthly Cost | Hourly Cost |
|--------------|-----------|--------------|-------------|
| Minimal | Master + 1 Worker | ~$60 | ~$0.08 |
| Medium | + Tools | ~$110 | ~$0.15 |
| Full | + Worker 2 + Monitoring | ~$200 | ~$0.27 |

**For Learning:** Use `terraform destroy` after each session!

## Common Commands

### Initialize & Deploy

```bash
terraform init
terraform plan
terraform apply
```

### View Outputs

```bash
terraform output                                    # All outputs
terraform output jenkins_url                        # Specific output
terraform output -json > outputs.json              # JSON format
```

### SSH Access

```bash
# Get SSH commands
terraform output ssh_commands

# SSH to Jenkins master
ssh -i ../k8s-pipeline-key.pem ubuntu@$(terraform output -raw jenkins_k8s_master_public_ip)
```

### Update Infrastructure

```bash
# Change variables in terraform.auto.tfvars
terraform plan    # Review changes
terraform apply   # Apply changes
```

### Destroy Infrastructure

```bash
terraform destroy  # Remove all resources
```

## Post-Deployment Configuration

### 1. Initialize Kubernetes

```bash
# SSH to master
ssh -i ../k8s-pipeline-key.pem ubuntu@<MASTER_IP>

# Run initialization script
/home/ubuntu/init-k8s-master.sh

# Get join command for workers
kubeadm token create --print-join-command
```

### 2. Join Worker Nodes

```bash
# SSH to each worker
ssh -i ../k8s-pipeline-key.pem ubuntu@<WORKER_IP>

# Run join command from master
sudo kubeadm join ...
```

### 3. Configure Jenkins

```bash
# Get admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Access UI
http://<JENKINS_IP>:8080
```

See **SETUP-GUIDE.md** in parent directory for complete configuration steps.

## Outputs

Terraform provides these outputs:

### URLs
- `jenkins_url` - Jenkins UI
- `nexus_url` - Nexus repository
- `sonarqube_url` - SonarQube dashboard
- `prometheus_url` - Prometheus metrics
- `grafana_url` - Grafana dashboards

### IP Addresses
- Public IPs for SSH access
- Private IPs for service discovery

### DNS Names
- Service discovery endpoints

### SSH Commands
- Ready-to-use SSH commands for each instance

### OIDC
- `github_actions_role_arn` - Role ARN for GitHub Actions

## Troubleshooting

### Issue: `terraform apply` fails

**Check AWS credentials:**
```bash
aws sts get-caller-identity
```

### Issue: Can't SSH to instances

**Check key permissions:**
```bash
chmod 400 ../k8s-pipeline-key.pem
```

**Verify security group:**
```bash
terraform output ssh_commands
# Ensure allowed_cidr includes your IP
```

### Issue: Service discovery not working

**Verify from any EC2 instance:**
```bash
nslookup jenkins-k8s-master.ultimate-cicd-devops.local
```

**Should resolve to private IP (172.31.x.x)**

### Issue: Deprecated warnings

```
"failure_threshold" is deprecated
```

**This is non-breaking** - AWS Cloud Map still works, they're just updating the API.

## Additional Documentation

## Related Documentation

- **ARCHITECTURE.md** - System design and architecture
- **QUICKREF.md** - Command reference and troubleshooting
- **../guides/00-START-HERE.md** - Complete step-by-step setup guides
- **../docs/QUICK-REFERENCE.md** - Quick reference card

## Best Practices

### Development Workflow

1. Make changes to `.tf` or `.tfvars` files
2. Run `terraform plan` to preview changes
3. Review plan output carefully
4. Run `terraform apply` to apply changes
5. Verify outputs and test connectivity

### Security

- Use specific CIDR for SSH (`YOUR_IP/32`)
- Enable instance profiles for EC2-to-AWS access
- Use OIDC for GitHub Actions (no stored credentials)
- Rotate SSH keys periodically
- Use security groups to restrict access

### Cost Management

- Use feature flags to disable unused services
- Run `terraform destroy` after learning sessions
- Use `t3.medium` instead of larger instances
- Monitor AWS billing dashboard
- Set up billing alerts in AWS

## Updates & Maintenance

### Updating Terraform

```bash
terraform version          # Check current version
brew upgrade terraform     # macOS
# or download from terraform.io
```

### Updating AWS Provider

```bash
# providers.tf is implicit, using required_version
terraform init -upgrade
```

### Updating Scripts

Installation scripts in `scripts/` are templated by Terraform:
- Edit script file
- Run `terraform apply` to update user_data
- **Note:** Changes only apply to new instances

## Notes

- **Default VPC**: Using AWS default VPC for simplicity
- **Ubuntu 24.04 LTS**: Specified in `terraform.auto.tfvars`
- **Service Discovery**: Private DNS namespace (VPC-only)
- **OIDC**: Optional, can be disabled
- **Remote State**: Backend config exists but commented out

## Next Steps

After successful deployment:

1. Follow **../guides/00-START-HERE.md** for complete setup walkthrough
2. Initialize Kubernetes cluster (see guide 05-kubernetes-setup.md)
3. Configure Jenkins pipeline (see guide 06-jenkins-setup.md)
4. Deploy sample application (see guide 09-pipeline-setup.md)
5. Monitor with Prometheus/Grafana (see guide 10-verification.md)

---

**For detailed setup instructions, see SETUP-GUIDE.md in the parent directory.**

**For architecture details, see ARCHITECTURE.md in this directory.**
