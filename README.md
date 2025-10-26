# Ultimate CI/CD DevOps Pipeline

A complete production-grade CI/CD pipeline for deploying a Java Spring Boot application on AWS using Jenkins, Kubernetes, Docker, SonarQube, Nexus, and comprehensive monitoring.

**Status:** ✅ Tested and Working | **Last Updated:** October 25, 2025


## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Quick Start](#quick-start)
- [Documentation](#documentation)
- [Infrastructure](#infrastructure)
- [Project Structure](#project-structure)
- [Application](#application)
- [Prerequisites](#prerequisites)
- [Cost Information](#cost-information)
- [Support](#support)


## Overview

This project provides a **complete, automated CI/CD pipeline** running on AWS infrastructure. It includes everything you need to build, test, analyze, containerize, and deploy a Java Spring Boot application.

**What's Included:**
- 5 EC2 instances managed by Terraform
- Kubernetes cluster (1 master + 2 workers)
- Complete Jenkins CI/CD pipeline (11 stages)
- Code quality analysis (SonarQube)
- Artifact management (Nexus)
- Container security scanning (Trivy)
- Infrastructure monitoring (Prometheus + Grafana)
- AWS Cloud Map service discovery
- Optional GitHub Actions OIDC authentication


## Features

### Infrastructure
✅ **Infrastructure as Code** - Complete Terraform configuration with object-based variables  
✅ **Service Discovery** - AWS Cloud Map DNS for internal service communication  
✅ **OIDC Authentication** - GitHub Actions can deploy without AWS credentials  
✅ **IAM Instance Profiles** - EC2 instances access AWS services securely  
✅ **Automated Setup** - All services installed via cloud-init scripts  
✅ **Cost Controls** - Toggle optional instances to save money  

### CI/CD Pipeline
✅ **Automated Builds** - Git commit triggers full pipeline  
✅ **Code Quality** - SonarQube analysis with quality gates  
✅ **Security Scanning** - Trivy scans Docker images for vulnerabilities  
✅ **Artifact Storage** - Maven artifacts stored in Nexus  
✅ **Container Registry** - Docker images pushed to Docker Hub/ECR  
✅ **Auto-Deployment** - Kubernetes deployment with health verification  

### Monitoring
✅ **Metrics Collection** - Prometheus scrapes system and application metrics  
✅ **Visualization** - Grafana dashboards for infrastructure and K8s  
✅ **Alerting** - Prometheus alert rules (customizable)  


## Quick Start

**For complete step-by-step instructions, see the [Setup Guides](guides/00-START-HERE.md)**

### 1. Configure Infrastructure

```bash
cd terraform/
cp terraform.auto.tfvars.example terraform.auto.tfvars
# Edit terraform.auto.tfvars with your settings
```

### 2. Deploy Infrastructure

```bash
terraform init
terraform plan
terraform apply
```

### 3. Initialize Kubernetes

```bash
# SSH to master (use output from terraform)
ssh -i k8s-pipeline-key.pem ubuntu@<MASTER_IP>

# Run initialization script
/home/ubuntu/init-k8s-master.sh
```

### 4. Configure Services

Follow the detailed guides:
- [Jenkins Configuration](guides/06-jenkins-setup.md)
- [SonarQube Setup](guides/07-sonarqube-setup.md)
- [Nexus Setup](guides/08-nexus-setup.md)

### 5. Run Pipeline

Create Jenkins pipeline job pointing to `ci-cd/Jenkinsfile` and trigger build.

**Total setup time:** ~3 hours for first-time setup


## Documentation

### 📖 Getting Started Guides

**Start here for hands-on learning:**

```
guides/
├── 00-START-HERE.md          Master navigation and overview
├── 01-architecture.md        System architecture (5 min)
├── 02-aws-setup.md          AWS prerequisites (15 min)
├── 03-local-setup.md        Terraform configuration (10 min)
├── 04-terraform-deploy.md   Infrastructure deployment (20 min)
├── 05-kubernetes-setup.md   K8s cluster initialization (20 min)
├── 06-jenkins-setup.md      Jenkins configuration (40 min)
├── 07-sonarqube-setup.md    SonarQube setup (15 min)
├── 08-nexus-setup.md        Nexus configuration (20 min)
├── 09-pipeline-setup.md     Pipeline creation (30 min)
└── 10-verification.md       Testing and teardown (25 min)
```

**[→ Start with the guides](guides/00-START-HERE.md)**


### 📚 Reference Documentation

- **[Quick Reference](docs/QUICK-REFERENCE.md)** - Commands, URLs, credentials cheat sheet
- **[Terraform Infrastructure](terraform/README.md)** - Infrastructure details and configuration
- **[Architecture Deep Dive](terraform/ARCHITECTURE.md)** - System design and component interaction
- **[Terraform Quick Ref](terraform/QUICKREF.md)** - Terraform-specific commands


## Infrastructure

### Components

**5 EC2 Instances (all t3.medium):**

1. **Jenkins + K8s Master** (combined)
   - Jenkins CI/CD server (port 8080)
   - Kubernetes master node
   - kubectl, kubeadm, containerd

2. **K8s Worker 1**
   - Kubernetes worker node
   - Runs application pods

3. **K8s Worker 2**
   - Kubernetes worker node
   - Provides redundancy

4. **Nexus + SonarQube** (combined)
   - Nexus Repository (port 8081)
   - SonarQube code analysis (port 9000)

5. **Prometheus + Grafana** (combined)
   - Prometheus metrics (port 9090)
   - Grafana dashboards (port 3000)

### Service Discovery

Internal DNS names via AWS Cloud Map:

```
jenkins-k8s-master.ultimate-cicd-devops.local
k8s-worker-1.ultimate-cicd-devops.local
k8s-worker-2.ultimate-cicd-devops.local
nexus-sonarqube.ultimate-cicd-devops.local
prometheus-grafana.ultimate-cicd-devops.local
```

### Network Architecture

- **VPC:** Default VPC (configurable)
- **Security Groups:** Per-instance with minimal required access
- **SSH Access:** Restricted to your IP (configure in tfvars)
- **Service Communication:** Internal via service discovery DNS


## Project Structure

```
.
├── app/                          # Java Spring Boot Application
│   ├── src/                      # Application source code
│   ├── pom.xml                   # Maven configuration (Java 17)
│   ├── Dockerfile                # Container image definition
│   └── mvnw*                     # Maven wrapper
│
├── ci-cd/                        # CI/CD Configuration
│   ├── Jenkinsfile               # 11-stage pipeline definition
│   └── sonar-project.properties  # SonarQube analysis config
│
├── kubernetes/                   # Kubernetes Manifests
│   └── deployment-service.yaml   # Deployment & LoadBalancer service
│
├── terraform/                    # Infrastructure as Code
│   ├── main.tf                   # EC2 instances
│   ├── variables.tf              # Variable definitions
│   ├── terraform.auto.tfvars     # Your configuration
│   ├── sg.tf                     # Security groups
│   ├── iam.tf                    # IAM roles & OIDC
│   ├── service-discovery.tf      # AWS Cloud Map
│   ├── outputs.tf                # Output values
│   ├── backend.tf                # Remote state (optional)
│   ├── README.md                 # Terraform documentation
│   ├── ARCHITECTURE.md           # Architecture details
│   ├── QUICKREF.md               # Terraform quick reference
│   └── scripts/                  # Cloud-init installation scripts
│
├── guides/                       # Step-by-step setup guides
│   ├── 00-START-HERE.md          # Navigation and overview
│   ├── 01-architecture.md        # System architecture
│   ├── 02-aws-setup.md           # AWS prerequisites
│   ├── 03-local-setup.md         # Local environment setup
│   ├── 04-terraform-deploy.md    # Infrastructure deployment
│   ├── 05-kubernetes-setup.md    # K8s initialization
│   ├── 06-jenkins-setup.md       # Jenkins configuration
│   ├── 07-sonarqube-setup.md     # SonarQube setup
│   ├── 08-nexus-setup.md         # Nexus configuration
│   ├── 09-pipeline-setup.md      # Pipeline creation
│   └── 10-verification.md        # Testing and teardown
│
├── docs/                         # Additional documentation
│   └── QUICK-REFERENCE.md        # Quick reference card
│
├── README.md                     # This file
└── .github-workflow-example.yml  # GitHub Actions OIDC template
```


## Application

**BoardGame Database Web Application**

A full-stack Java Spring Boot application for managing board game collections.

### Technologies
- **Backend:** Java 17, Spring Boot 2.5.6, Spring MVC, Spring Security
- **Frontend:** Thymeleaf, HTML5, CSS, Bootstrap, JavaScript
- **Database:** H2 (embedded, in-memory)
- **Build:** Maven 3.6+
- **Testing:** JUnit

### Features
- Board game listing and search
- User authentication (Spring Security)
- Role-based access control (User, Manager)
- Responsive web UI
- RESTful API

### Test Credentials
- User: `bugs` / Password: `bunny` (user role)
- User: `daffy` / Password: `duck` (manager role)

### Local Development

```bash
cd app/
./mvnw spring-boot:run
# Access http://localhost:8080
```


## Prerequisites

### Required
- **AWS Account** with admin or power user permissions
- **AWS CLI** installed and configured
- **Terraform** >= 1.0
- **SSH Key Pair** created in AWS EC2
- **Git** for version control

### Optional
- **Docker Hub Account** (or use AWS ECR)
- **Java 17+** and **Maven** (for local development)
- **kubectl** (for local K8s management)

### AWS Permissions Required
- EC2 (instances, security groups, key pairs)
- IAM (roles, policies, OIDC providers)
- Route 53 (for Cloud Map service discovery)
- Systems Manager (optional, for parameter store)


## Cost Information

### Estimated Monthly Costs

**Minimum Setup** (Master + 1 Worker):
- 2 × t3.medium instances
- ~$50-60/month if running 24/7

**Full Setup** (All 5 Instances):
- 5 × t3.medium instances
- ~$200-250/month if running 24/7

**Learning Mode** (Recommended):
- Deploy for 4-hour sessions
- Run `terraform destroy` after each session
- Cost per session: ~$0.67
- Monthly cost: ~$10-15 (if used 3-4 times/week)

### Cost Optimization Options

**Disable optional instances in `terraform.auto.tfvars`:**

```hcl
feature_flags = {
  enable_monitoring_instance = false  # Saves ~$40/month
  enable_tools_instance      = false  # Saves ~$40/month
  enable_worker_2            = false  # Saves ~$40/month
}
```

**Stop instances when not in use:**

```bash
# Stop all instances (data persists)
aws ec2 stop-instances --instance-ids $(terraform output -json | jq -r '.*.value[]')

# Or destroy completely (removes everything)
terraform destroy
```


## CI/CD Pipeline Stages

The Jenkins pipeline executes 11 stages:

1. **Git Checkout** - Clone repository
2. **Compile** - Maven compile
3. **Unit Tests** - Run JUnit tests
4. **SonarQube Analysis** - Code quality scan
5. **Quality Gate** - Wait for SonarQube results
6. **Build** - Maven package (create JAR)
7. **Publish to Nexus** - Upload artifact
8. **Build Docker Image** - Create container image
9. **Trivy Scan** - Security vulnerability scan
10. **Push to Docker Hub** - Upload image to registry
11. **Deploy to Kubernetes** - Apply K8s manifests and verify

**Total pipeline time:** 8-12 minutes (first build), 5-8 minutes (subsequent)


## Service URLs

After deployment (get from `terraform output`):

```
Jenkins:     http://<JENKINS_IP>:8080
SonarQube:   http://<NEXUS_SONARQUBE_IP>:9000
Nexus:       http://<NEXUS_SONARQUBE_IP>:8081
Prometheus:  http://<PROMETHEUS_IP>:9090
Grafana:     http://<PROMETHEUS_IP>:3000
Application: http://<WORKER_IP>:<NODE_PORT>
```

### Default Credentials

**Jenkins:**
- Initial password: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
- Set during first login

**SonarQube:**
- Default: `admin` / `admin`
- Change on first login

**Nexus:**
- Initial password: `docker exec nexus cat /nexus-data/admin.password`
- Recommended: `admin` / `admin123` (matches Maven settings)

**Grafana:**
- Default: `admin` / `admin`
- Change on first login


## Support

### Getting Help

1. **Check the guides:** [guides/00-START-HERE.md](guides/00-START-HERE.md)
2. **Quick reference:** [docs/QUICK-REFERENCE.md](docs/QUICK-REFERENCE.md)
3. **Troubleshooting:** Each guide has a troubleshooting section
4. **Terraform issues:** See [terraform/README.md](terraform/README.md)

### Common Issues

**Can't SSH to instances:**
```bash
# Check key permissions
chmod 400 k8s-pipeline-key.pem

# Verify your IP in security group
curl ifconfig.me
```

**Pipeline fails:**
- Check Jenkins console output for specific error
- Verify all credentials are configured
- Ensure services are accessible via service discovery

**Kubernetes pods not running:**
```bash
kubectl get pods -n webapps
kubectl describe pod <pod-name> -n webapps
kubectl logs <pod-name> -n webapps
```


## What You'll Learn

By completing this project, you'll gain hands-on experience with:

- **Infrastructure as Code** - Terraform for AWS resources
- **Container Orchestration** - Kubernetes cluster management
- **CI/CD Pipelines** - Jenkins multi-stage automation
- **Code Quality** - SonarQube analysis and quality gates
- **Security** - Container scanning with Trivy
- **Artifact Management** - Nexus repository configuration
- **Monitoring** - Prometheus metrics and Grafana dashboards
- **Service Discovery** - AWS Cloud Map DNS
- **Authentication** - OIDC for GitHub Actions
- **DevOps Best Practices** - Complete production-like workflow


## Next Steps

After successful deployment:

1. **Customize the pipeline** - Add integration tests, performance tests
2. **Enhance Kubernetes** - Add Ingress, autoscaling, secrets management
3. **Improve monitoring** - Custom metrics, alerts, dashboards
4. **Implement GitOps** - ArgoCD or Flux for declarative deployments
5. **Add security** - HashiCorp Vault, network policies, pod security
6. **Multi-environment** - Dev, staging, production configurations
7. **Blue-green deployments** - Zero-downtime releases


## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request


## License

This project is for educational and demonstration purposes.


## Acknowledgments

- Original boardgame application structure
- Enhanced with production-grade infrastructure
- Service discovery and OIDC integration
- Complete automation and monitoring


## Repository

**GitHub:** [temitayocharles/ultimate-pipeline](https://github.com/temitayocharles/ultimate-pipeline)


---

**Ready to get started?** → [Begin with the Setup Guides](guides/00-START-HERE.md)

**Need quick reference?** → [Quick Reference Card](docs/QUICK-REFERENCE.md)

**Want to understand the architecture?** → [Architecture Guide](terraform/ARCHITECTURE.md)

---

**Made for DevOps learning and practice** | **Status:** ✅ Tested and Working
