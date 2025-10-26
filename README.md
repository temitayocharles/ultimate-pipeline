# EC2 Kubernetes CI/CD Infrastructure

Terraform configuration for deploying a complete CI/CD and Kubernetes infrastructure on AWS with service discovery and OIDC authentication.

## Infrastructure

- **Jenkins + K8s Master** (combined): t3.medium
- **K8s Worker Node 1**: t3.medium  
- **K8s Worker Node 2**: t3.medium (optional)
- **Nexus + SonarQube**: t3.medium (optional)
- **Prometheus + Grafana**: t3.medium (optional)

## Features

✅ **Object-based Variables** - Clean, structured configuration  
✅ **AWS Cloud Map Service Discovery** - Automatic DNS-based service discovery  
✅ **OIDC for GitHub Actions** - Passwordless AWS authentication (no secrets!)  
✅ **IAM Instance Profiles** - EC2 instances can access ECR, SSM without keys  
✅ **Automated Installation** - All services installed via user_data scripts  
✅ **Cost Controls** - Toggle optional instances to save money

## Quick Start

1. **Update `terraform.auto.tfvars`**:
   - Set `ssh_config.key_name` (AWS SSH key pair)
   - Update `ssh_config.allowed_cidr` with your IP
   - Set `oidc_config.github_org` and `oidc_config.github_repo` if using GitHub Actions
   - Verify `ami_config.id` for your region
   - Toggle `feature_flags` to enable/disable optional instances

2. **Deploy**:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

3. **Access Services**: Check outputs for IPs and URLs

4. **Initialize K8s**: SSH to master and run `/home/ubuntu/init-k8s-master.sh`

## Service Discovery

Services can discover each other using AWS Cloud Map DNS:

- `jenkins-k8s-master.ultimate-cicd-devops.local`
- `k8s-worker-1.ultimate-cicd-devops.local`
- `tools.ultimate-cicd-devops.local` (Nexus/SonarQube)
- `monitoring.ultimate-cicd-devops.local` (Prometheus/Grafana)

## GitHub Actions OIDC Setup

1. Deploy infrastructure with `oidc_config.enable_github_oidc = true`
2. Get role ARN: `terraform output github_actions_role_arn`
3. Add to GitHub repo secrets as `AWS_ROLE_ARN`
4. Use `.github-workflow-example.yml` as template
5. No AWS credentials needed in GitHub!

## Cost Optimization

- **Minimum setup** (Master + 1 Worker): ~$50/month
- **Full setup** (All 5 instances): ~$200-250/month
- Set `enable_*` in `feature_flags` to `false` to disable optional instances
- **Stop instances when not in use!**

## Remote State (Optional)

See `backend.tf` for S3 backend setup instructions for team sharing.

## Service Access

After deployment, get credentials:

- **Jenkins**: `ssh ubuntu@<master-ip> 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'`
- **Nexus**: `ssh ubuntu@<tools-ip> '/home/ubuntu/get-nexus-password.sh'`
- **SonarQube**: Default is `admin/admin`
- **Grafana**: Default is `admin/admin`
