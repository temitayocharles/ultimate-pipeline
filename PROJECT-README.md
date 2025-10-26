# Ultimate CI/CD DevOps Pipeline Project

A complete end-to-end CI/CD pipeline for deploying a Java Spring Boot boardgame listing application on AWS using Jenkins, Kubernetes, Docker, SonarQube, Nexus, and comprehensive monitoring.

## 🏗️ Project Structure

```
.
├── app/                          # Java Spring Boot Application
│   ├── src/                      # Application source code
│   ├── pom.xml                   # Maven configuration
│   ├── Dockerfile                # Container image definition
│   └── mvnw*                     # Maven wrapper scripts
│
├── ci-cd/                        # CI/CD Configuration
│   ├── Jenkinsfile               # Jenkins pipeline definition
│   └── sonar-project.properties  # SonarQube analysis config
│
├── kubernetes/                   # Kubernetes Manifests
│   └── deployment-service.yaml   # K8s deployment & service
│
├── terraform/                    # Infrastructure as Code
│   ├── main.tf                   # EC2 instances
│   ├── variables.tf              # Variable definitions
│   ├── terraform.auto.tfvars     # Configuration values
│   ├── sg.tf                     # Security groups
│   ├── iam.tf                    # IAM roles & OIDC
│   ├── service-discovery.tf      # AWS Cloud Map
│   ├── outputs.tf                # Output values
│   ├── backend.tf                # Remote state config
│   └── scripts/                  # Installation scripts
│       ├── jenkins-k8s-master-setup.sh
│       ├── k8s-worker-setup.sh
│       ├── nexus-sonarqube-setup.sh
│       └── monitoring-setup.sh
│
├── docs/                         # Documentation
│   ├── infrastructure-details.json
│   └── infrastructure-details.txt
│
├── README.md                     # Infrastructure README
├── ARCHITECTURE.md               # Architecture documentation
├── QUICKREF.md                   # Quick reference guide
└── .github-workflow-example.yml  # GitHub Actions OIDC template
```

## 🚀 Application Overview

**BoardGame Listing Web Application**
- Full-stack Java Spring Boot application
- Board game database with user reviews
- Role-based access control (users, managers)
- Authentication via Spring Security
- Responsive UI with Thymeleaf and Bootstrap
- H2 in-memory database

**Technologies:**
- Java, Spring Boot, Spring MVC, Spring Security
- Thymeleaf, HTML5, CSS, JavaScript, Bootstrap
- JDBC, H2 Database
- JUnit for testing
- Maven build tool

## 🏗️ Infrastructure

**AWS Resources (managed by Terraform):**
- Jenkins + K8s Master (combined): t3.medium
- K8s Worker Node 1: t3.medium
- K8s Worker Node 2: t3.medium (optional)
- Nexus + SonarQube: t3.medium (optional)
- Prometheus + Grafana: t3.medium (optional)

**Features:**
- ✅ AWS Cloud Map service discovery
- ✅ OIDC authentication for GitHub Actions
- ✅ IAM instance profiles for EC2
- ✅ Automated installation scripts
- ✅ Cost-optimized with toggle options

## 📋 Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** configured with credentials
3. **Terraform** >= 1.0
4. **Git** for version control
5. **SSH Key Pair** in AWS (e.g., `k8s-pipeline-key`)
6. **Java 17+** and **Maven** (for local development)

## 🎯 Quick Start

### 1. Configure Infrastructure

Edit `terraform/terraform.auto.tfvars`:
```hcl
ssh_config = {
  key_name     = "k8s-pipeline-key"  # Your AWS key pair
  allowed_cidr = ["YOUR_IP/32"]      # Your IP for SSH
}

oidc_config = {
  github_org         = "temitayocharles"
  github_repo        = "ultimate-pipeline"
  enable_github_oidc = true
}
```

### 2. Deploy Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 3. Initialize Kubernetes

```bash
# SSH to master
ssh -i k8s-pipeline-key.pem ubuntu@<master-ip>

# Initialize K8s cluster
/home/ubuntu/init-k8s-master.sh

# Get join command
kubeadm token create --print-join-command

# On each worker, run the join command
```

### 4. Access Services

```bash
# Get service URLs
terraform output

# Jenkins: http://<master-ip>:8080
# Nexus: http://<tools-ip>:8081
# SonarQube: http://<tools-ip>:9000
# Grafana: http://<monitoring-ip>:3000
```

### 5. Configure Jenkins Pipeline

1. Access Jenkins UI
2. Install required plugins:
   - Kubernetes
   - Docker Pipeline
   - SonarQube Scanner
   - Nexus Artifact Uploader
3. Configure credentials:
   - Docker Hub
   - SonarQube token
   - Nexus credentials
4. Create pipeline using `ci-cd/Jenkinsfile`

### 6. Deploy Application

```bash
# Using Jenkins pipeline (automated)
# Or manually:
kubectl apply -f kubernetes/deployment-service.yaml
```

## 🔄 CI/CD Pipeline Flow

1. **Code Commit** → Push to GitHub
2. **Jenkins Triggered** → Webhook or manual
3. **Build** → Maven compiles Java code
4. **Test** → JUnit tests executed
5. **Code Analysis** → SonarQube scans code quality
6. **Build Image** → Docker image created
7. **Push to Registry** → Docker Hub or ECR
8. **Deploy to K8s** → kubectl applies manifests
9. **Monitor** → Prometheus & Grafana

## 🔐 Security Features

- **OIDC Authentication**: GitHub Actions → AWS (no secrets!)
- **IAM Instance Profiles**: EC2 → AWS services
- **Security Groups**: Restricted SSH access
- **Spring Security**: Role-based access control
- **Secrets Management**: Jenkins credentials store

## 📊 Monitoring Stack

**Prometheus** collects metrics from:
- Node Exporter (system metrics)
- Kubernetes metrics
- Jenkins metrics
- Application metrics

**Grafana** dashboards for:
- Infrastructure monitoring
- Kubernetes cluster health
- Application performance
- CI/CD pipeline metrics

## 💰 Cost Optimization

**Minimum Setup** (~$60/month):
```hcl
feature_flags = {
  enable_monitoring_instance = false
  enable_tools_instance      = false
  enable_worker_2            = false
}
```

**Full Setup** (~$200-250/month):
All instances enabled

**For Learning**: Run `terraform destroy` after each session!

## 🧪 Testing the Application

**Locally:**
```bash
cd app
./mvnw spring-boot:run
# Access: http://localhost:8080
```

**Test Credentials:**
- Username: `bugs` | Password: `bunny` (user role)
- Username: `daffy` | Password: `duck` (manager role)

## 🔧 Troubleshooting

**Infrastructure Issues:**
- Check terraform outputs: `terraform output`
- Verify security groups: `terraform state show aws_security_group.jenkins_sg`
- Test service discovery: `nslookup jenkins-k8s-master.ultimate-cicd-devops.local`

**Application Issues:**
- Check Jenkins logs: `ssh ubuntu@<master-ip> 'sudo journalctl -u jenkins'`
- Verify K8s pods: `kubectl get pods`
- Check application logs: `kubectl logs <pod-name>`

## 📚 Documentation

- [Infrastructure README](README.md) - Terraform infrastructure guide
- [Architecture](ARCHITECTURE.md) - Detailed architecture explanation
- [Quick Reference](QUICKREF.md) - Commands and troubleshooting
- [Docs folder](docs/) - Additional infrastructure details

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

## 📝 License

This project is for educational and demonstration purposes.

## 👏 Credits

- Original application: BoardGame Listing Web App
- Infrastructure templates: Enhanced with OIDC, service discovery, and automation
- CI/CD pipeline: Jenkins, SonarQube, Nexus integration

## 🔗 Related Projects

- [Original Repository](https://github.com/anniedjatsa/THE-ULTIMATE-CICD-DEVOPS-PIPELINE-PROJECT-01)
- [Your Ultimate Pipeline](https://github.com/temitayocharles/ultimate-pipeline)

---

**Made with ❤️ for DevOps learning and practice**
