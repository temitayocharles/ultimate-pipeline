# Quick Reference

## File Structure
```
├── main.tf                         # EC2 instances
├── variables.tf                    # Core variable definitions (object types)
├── variables-oidc.tf              # OIDC/IAM variable definitions
├── terraform.auto.tfvars          # All default values (customize this!)
├── sg.tf                          # Security groups
├── iam.tf                         # IAM roles, OIDC provider, instance profiles
├── service-discovery.tf           # AWS Cloud Map service discovery
├── outputs.tf                     # Outputs (IPs, URLs, DNS names, OIDC info)
├── backend.tf                     # Remote state config (optional)
├── scripts/
│   ├── jenkins-k8s-master-setup.sh
│   ├── k8s-worker-setup.sh
│   ├── nexus-sonarqube-setup.sh
│   └── monitoring-setup.sh
├── .gitignore
├── .github-workflow-example.yml   # GitHub Actions OIDC example
├── README.md
└── ARCHITECTURE.md
```

## Key Customization Points

**terraform.auto.tfvars:**
- `ssh_config.key_name` - Your AWS SSH key pair name REQUIRED
- `ssh_config.allowed_cidr` - Your IP for SSH access (security)
- `ami_config.id` - Verify for your region
- `oidc_config.github_org/repo` - If using GitHub Actions
- `feature_flags.*` - Enable/disable optional instances

## Quick Commands

```bash
# Initial deployment
terraform init
terraform plan
terraform apply

# Get outputs
terraform output
terraform output jenkins_k8s_master_public_ip
terraform output github_actions_role_arn

# Check service discovery DNS names
terraform output service_discovery_dns_endpoints

# Update configuration
# Edit terraform.auto.tfvars, then:
terraform plan
terraform apply

# Destroy everything
terraform destroy
```

## Post-Deployment Steps

1. **Initialize Kubernetes Master:**
   ```bash
   ssh -i your-key.pem ubuntu@<master-ip>
   /home/ubuntu/init-k8s-master.sh
   ```

2. **Join Worker Nodes:**
   ```bash
   # On master, get join command:
   kubeadm token create --print-join-command
   
   # On each worker:
   ssh -i your-key.pem ubuntu@<worker-ip>
   sudo <paste-join-command>
   ```

3. **Get Service Credentials:**
   ```bash
   # Jenkins password
   ssh ubuntu@<master-ip> 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'
   
   # Nexus password
   ssh ubuntu@<tools-ip> '/home/ubuntu/get-nexus-password.sh'
   ```

4. **Setup GitHub Actions (if using OIDC):**
   ```bash
   # Get role ARN
   terraform output github_actions_role_arn
   
   # Add to GitHub repo secrets as: AWS_ROLE_ARN
   # Use .github-workflow-example.yml as template
   ```

## Cost Control

**To minimize costs:**
```hcl
# In terraform.auto.tfvars
feature_flags = {
  enable_monitoring_instance = false  # Save ~$25/month
  enable_tools_instance      = false  # Save ~$25/month
  enable_worker_2            = false  # Save ~$25/month
}
```

**Stop instances when not in use:**
```bash
# AWS CLI
aws ec2 stop-instances --instance-ids <instance-id>

# Start again
aws ec2 start-instances --instance-ids <instance-id>
```

## Troubleshooting

**SSH Connection Issues:**
- Check `ssh_config.allowed_cidr` includes your IP
- Verify security group rules: `terraform state show aws_security_group.jenkins_sg`
- Get current IP: `curl ifconfig.me`

**Service Discovery Not Working:**
- Only works within VPC (not from internet)
- SSH to an instance and test: `nslookup jenkins-k8s-master.ultimate-cicd-devops.local`
- Verify service registration: `aws servicediscovery list-services`

**OIDC Authentication Failed:**
- Verify `github_org` and `github_repo` match exactly
- Check GitHub workflow has `permissions: id-token: write`
- Role ARN must be in GitHub secrets as `AWS_ROLE_ARN`

**Terraform State Locked:**
- If using remote backend with DynamoDB
- Check DynamoDB for lock item
- Force unlock (use carefully): `terraform force-unlock <lock-id>`
