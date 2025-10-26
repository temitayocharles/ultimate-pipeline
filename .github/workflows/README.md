# GitHub Actions CI/CD Pipeline

This directory contains GitHub Actions workflows that provide an alternative to the Jenkins pipeline.

## Overview

The `ci-cd-pipeline.yml` workflow replicates the entire Jenkins pipeline using GitHub Actions:

- **Build** → **Test** → **SonarQube** → **Package** → **Docker** → **Scan** → **Deploy**

## Features

- Uses AWS OIDC (no stored credentials needed!)
- Parallel job execution for faster builds
- Integrated security scanning (Trivy)
- Artifact caching for Maven and Docker
- Conditional deployment (main branch only)
- Manual trigger support

## Required GitHub Secrets

Before running the workflow, configure these secrets in your GitHub repository:

### Repository Settings → Secrets and Variables → Actions → New repository secret

| Secret Name | Description | Example/Value |
|------------|-------------|---------------|
| `DOCKER_USERNAME` | Your Docker Hub username | `temitayocharles` |
| `DOCKER_PASSWORD` | Your Docker Hub password or token | `dckr_pat_xxxxx` |
| `SONAR_TOKEN` | SonarQube authentication token | Generated from SonarQube |
| `NEXUS_USERNAME` | Nexus repository username | `admin` |
| `NEXUS_PASSWORD` | Nexus repository password | Your password |

### Getting SonarQube Token

```bash
# SSH into SonarQube server
ssh -i ~/.ssh/k8s-pipeline-key.pem ubuntu@<SONARQUBE_IP>

# Access SonarQube at http://<SONARQUBE_IP>:9000
# Login: admin / admin (change on first login)
# Go to: My Account → Security → Generate Token
# Copy token and add to GitHub Secrets
```

## Configuration Required

### 1. Update Workflow Variables

Edit `.github/workflows/ci-cd-pipeline.yml` and update:

```yaml
env:
  SONAR_HOST_URL: http://YOUR_SONARQUBE_IP:9000  # Get from terraform output
  NEXUS_URL: http://YOUR_NEXUS_IP:8081           # Get from terraform output
```

Get IPs from Terraform:
```bash
cd terraform/
terraform output sonarqube_url
terraform output nexus_url
```

### 2. Configure Kubernetes Access

The workflow uses AWS OIDC for authentication. For Kubernetes deployment on EC2, you need to:

**Option A: Use AWS Systems Manager**
```yaml
- name: Deploy via SSM
  run: |
    aws ssm send-command \
      --instance-ids i-xxxxx \
      --document-name "AWS-RunShellScript" \
      --parameters commands="kubectl set image deployment/boardgame boardgame=${{ env.DOCKER_IMAGE }}:${{ needs.setup.outputs.version }}"
```

**Option B: Store kubeconfig in Secrets**
```bash
# On your local machine (with kubectl configured)
cat ~/.kube/config | base64

# Add to GitHub Secrets as KUBE_CONFIG_DATA
```

Then in workflow:
```yaml
- name: Configure kubectl
  run: |
    mkdir -p ~/.kube
    echo "${{ secrets.KUBE_CONFIG_DATA }}" | base64 -d > ~/.kube/config
```

**Option C: SSH to Master Node**
```yaml
- name: Deploy via SSH
  uses: appleboy/ssh-action@v1.0.0
  with:
    host: ${{ secrets.K8S_MASTER_IP }}
    username: ubuntu
    key: ${{ secrets.SSH_PRIVATE_KEY }}
    script: |
      kubectl set image deployment/boardgame boardgame=${{ env.DOCKER_IMAGE }}:latest
```

## AWS OIDC Setup (Already Done!)

Your Terraform configuration already created the OIDC provider and IAM role:

- **OIDC Provider:** `token.actions.githubusercontent.com`
- **IAM Role:** `ultimate-cicd-devops-github-actions-role`
- **Trust Policy:** Configured for `temitayocharles/ultimate-pipeline`

The workflow automatically authenticates using:
```yaml
- uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::940482412089:role/ultimate-cicd-devops-github-actions-role
```

## How to Use

### Automatic Triggers

The workflow runs automatically on:
- **Push to main branch** → Full pipeline + deployment
- **Push to develop branch** → Build and test only
- **Pull requests to main** → Build, test, and validate

### Manual Trigger

1. Go to: **GitHub Repository → Actions → CI/CD Pipeline**
2. Click **Run workflow**
3. Select branch
4. Click **Run workflow**

## Workflow Jobs

```
setup
  ↓
build ─→ test ─→ sonarqube
  ↓              ↓
security-scan   package ─→ publish-nexus
                   ↓
                docker ─→ docker-scan ─→ deploy ─→ verify
                                          ↓
                                    notify (success/failure)
```

### Job Breakdown

1. **setup** - Checkout code, generate version
2. **build** - Compile with Maven
3. **test** - Run unit tests
4. **sonarqube** - Code quality analysis
5. **security-scan** - Trivy filesystem scan
6. **package** - Create JAR file
7. **publish-nexus** - Upload to Nexus (main branch only)
8. **docker** - Build and push Docker image
9. **docker-scan** - Trivy image vulnerability scan
10. **deploy** - Deploy to Kubernetes (main branch only)
11. **verify** - Post-deployment checks
12. **notify** - Success/failure notifications

## Viewing Results

### In GitHub Actions UI

- **Workflow Runs:** Actions tab → Select workflow run
- **Job Logs:** Click on any job to see detailed logs
- **Artifacts:** Download test results, scan reports

### External Tools

- **SonarQube:** http://SONARQUBE_IP:9000
- **Nexus:** http://NEXUS_IP:8081
- **Docker Hub:** https://hub.docker.com/r/temitayocharles/boardgame

## Comparison: Jenkins vs GitHub Actions

| Feature | Jenkins | GitHub Actions |
|---------|---------|----------------|
| **Infrastructure** | Self-hosted EC2 | GitHub-hosted runners |
| **Cost** | ~$30/month for t3.medium | Free (2,000 min/month) |
| **Setup** | Manual configuration | YAML file |
| **Credentials** | Stored in Jenkins | GitHub Secrets + OIDC |
| **Parallel Jobs** | Requires agents | Built-in |
| **UI** | Classic Jenkins UI | GitHub Actions UI |
| **Customization** | Plugins available | Actions Marketplace |
| **Learning Value** | Industry standard tool | Modern cloud-native |

## Troubleshooting

### Workflow Not Triggering

- Check if workflow file is in `.github/workflows/`
- Verify YAML syntax is valid
- Check branch name matches trigger

### Authentication Failures

```bash
# Verify OIDC role exists
aws iam get-role --role-name ultimate-cicd-devops-github-actions-role

# Check trust policy allows your repository
aws iam get-role --role-name ultimate-cicd-devops-github-actions-role \
  --query 'Role.AssumeRolePolicyDocument'
```

### Docker Push Fails

- Verify Docker Hub credentials in Secrets
- Check image name format
- Ensure Docker Hub repository exists

### SonarQube Scan Fails

- Verify SonarQube server is accessible
- Check SONAR_TOKEN is valid
- Ensure SonarQube server is running

## Best Practices

1. **Use Secrets for Sensitive Data** - Never commit credentials
2. **Pin Action Versions** - Use `@v4` instead of `@latest`
3. **Conditional Jobs** - Use `if:` to control when jobs run
4. **Caching** - Enable for Maven, Docker, npm
5. **Artifacts** - Save test results and reports
6. **Branch Protection** - Require status checks before merge

## Next Steps

1. Configure all required secrets
2. Update workflow with your IPs
3. Choose Kubernetes deployment method
4. Test with a push to main branch
5. Monitor workflow execution
6. Compare with Jenkins pipeline

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS OIDC with GitHub Actions](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [Trivy Action](https://github.com/aquasecurity/trivy-action)
