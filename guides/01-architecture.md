# Step 1: Architecture Overview

**Duration:** 10 minutes (reading and understanding)

**Goal:** Understand the complete system architecture before building it


---


## System Architecture

This CI/CD pipeline consists of 5 AWS EC2 instances working together to provide a complete DevOps environment.


### Infrastructure Components

**Instance 1: Jenkins and Kubernetes Master (Combined)**
* Purpose: CI/CD orchestration and Kubernetes control plane
* Instance Type: t3.medium (2 vCPU, 4 GB RAM)
* Services Running:
  * Jenkins (port 8080) - CI/CD automation
  * Kubernetes API Server (port 6443)
  * Kubernetes Controller Manager
  * Kubernetes Scheduler
  * etcd database for K8s state


**Instance 2: Kubernetes Worker Node 1**
* Purpose: Application workload execution
* Instance Type: t3.medium (2 vCPU, 4 GB RAM)
* Services Running:
  * kubelet - Node agent
  * kube-proxy - Network proxy
  * Container runtime (containerd)
  * Your application pods


**Instance 3: Kubernetes Worker Node 2**
* Purpose: Additional application capacity and high availability
* Instance Type: t3.medium (2 vCPU, 4 GB RAM)
* Services Running:
  * kubelet - Node agent
  * kube-proxy - Network proxy
  * Container runtime (containerd)
  * Your application pods


**Instance 4: Nexus and SonarQube (Combined)**
* Purpose: Artifact management and code quality analysis
* Instance Type: t3.medium (2 vCPU, 4 GB RAM)
* Services Running:
  * Nexus Repository (port 8081) - Maven artifacts, Docker registry
  * SonarQube (port 9000) - Code quality and security scanning


**Instance 5: Monitoring (Prometheus and Grafana)**
* Purpose: Metrics collection and visualization
* Instance Type: t3.medium (2 vCPU, 4 GB RAM)
* Services Running:
  * Prometheus (port 9090) - Metrics collection
  * Grafana (port 3000) - Metrics visualization
  * Node Exporter (port 9100) - System metrics


---


## Application Architecture

**Application Name:** BoardGame Database

**Technology Stack:**
* Java 17
* Spring Boot 2.5.6
* Spring Security for authentication
* H2 embedded database
* Thymeleaf templating
* Maven build tool


**Application Features:**
* Board game listing and details
* User reviews and ratings
* Role-based access control (User and Manager roles)
* Responsive web interface


---


## CI/CD Pipeline Flow

Understanding the complete pipeline workflow:


### Stage 1: Code Commit

```
Developer commits code to GitHub
    |
    v
GitHub webhook triggers Jenkins
```


### Stage 2: Build and Test

```
Jenkins pulls latest code
    |
    v
Maven compiles Java source code
    |
    v
JUnit executes unit tests
    |
    v
Tests must pass to continue
```


### Stage 3: Code Quality Analysis

```
SonarQube Scanner analyzes code
    |
    v
Code quality metrics calculated
    |
    v
Quality gate check (pass/fail)
    |
    v
Pipeline stops if quality gate fails
```


### Stage 4: Build Artifact

```
Maven packages application as JAR file
    |
    v
JAR uploaded to Nexus Repository
    |
    v
Version tagged and stored
```


### Stage 5: Container Image Creation

```
Docker builds container image
    |
    v
Application JAR included in image
    |
    v
Trivy scans image for vulnerabilities
    |
    v
Image pushed to Docker Hub
```


### Stage 6: Kubernetes Deployment

```
kubectl applies deployment manifest
    |
    v
Kubernetes pulls Docker image
    |
    v
Pods created on worker nodes
    |
    v
Service exposes application
    |
    v
Application accessible via LoadBalancer
```


### Stage 7: Monitoring

```
Prometheus scrapes metrics from:
    - Application endpoints
    - Kubernetes cluster
    - System resources
    |
    v
Grafana visualizes metrics in dashboards
```


---


## Network Architecture

**AWS VPC Configuration:**
* All instances in default VPC
* All instances in same availability zone
* Security groups control traffic flow


**Security Group Rules:**

**SSH Access (Port 22):**
* Source: Your IP address only
* Protocol: TCP
* Purpose: Administrative access


**Jenkins (Port 8080):**
* Source: Your IP address
* Protocol: TCP
* Purpose: Web UI access


**Kubernetes API (Port 6443):**
* Source: Worker nodes
* Protocol: TCP
* Purpose: Worker-to-master communication


**Nexus (Port 8081):**
* Source: Jenkins master, your IP
* Protocol: TCP
* Purpose: Artifact repository access


**SonarQube (Port 9000):**
* Source: Jenkins master, your IP
* Protocol: TCP
* Purpose: Code analysis dashboard


**Prometheus (Port 9090):**
* Source: Grafana, your IP
* Protocol: TCP
* Purpose: Metrics API


**Grafana (Port 3000):**
* Source: Your IP
* Protocol: TCP
* Purpose: Dashboard access


---


## Service Discovery

**AWS Cloud Map Integration:**

Instead of using hardcoded IP addresses, instances communicate using DNS names.


**Internal DNS Names:**

```
jenkins-k8s-master.ultimate-cicd-devops.local
k8s-worker-1.ultimate-cicd-devops.local
k8s-worker-2.ultimate-cicd-devops.local
nexus-sonarqube.ultimate-cicd-devops.local
monitoring.ultimate-cicd-devops.local
```


**Benefits:**
* No IP address hardcoding
* Automatic DNS updates when instances change
* Works across entire VPC
* Simplifies configuration


---


## Authentication and Authorization

**AWS OIDC for GitHub Actions:**

OpenID Connect provider allows GitHub Actions to authenticate with AWS without storing credentials.


**How it works:**

```
GitHub Action runs
    |
    v
Requests temporary credentials from AWS STS
    |
    v
AWS validates GitHub identity using OIDC
    |
    v
Temporary credentials issued (valid 1 hour)
    |
    v
GitHub Action deploys to AWS
```


**IAM Instance Profiles:**

EC2 instances have IAM roles attached for AWS service access:

* Jenkins/K8s Master: ECR pull, SSM access, CloudWatch logs
* K8s Workers: ECR pull, SSM access, CloudWatch logs


---


## Data Flow Example

**Complete workflow for a code commit:**


**Step 1:** Developer pushes code to GitHub repository

**Step 2:** GitHub webhook notifies Jenkins of new commit

**Step 3:** Jenkins clones repository to workspace

**Step 4:** Maven compiles Java code and runs tests

**Step 5:** SonarQube analyzes code quality

**Step 6:** Maven packages JAR file

**Step 7:** JAR uploaded to Nexus repository

**Step 8:** Docker builds image with application JAR

**Step 9:** Trivy scans Docker image for vulnerabilities

**Step 10:** Docker image pushed to Docker Hub

**Step 11:** kubectl applies Kubernetes deployment

**Step 12:** Kubernetes pulls image from Docker Hub

**Step 13:** Pods scheduled on worker nodes

**Step 14:** Service creates LoadBalancer endpoint

**Step 15:** Application accessible to users

**Step 16:** Prometheus collects application metrics

**Step 17:** Grafana displays metrics in dashboards


---


## Why This Architecture

**Cost Optimization:**
* Combined Jenkins and K8s master on one instance
* Combined Nexus and SonarQube on one instance
* Reduces from 7 to 5 instances
* Savings: Approximately $100/month


**High Availability:**
* Two worker nodes for application redundancy
* Kubernetes automatically restarts failed pods
* Load balancing across multiple pod replicas


**Security:**
* OIDC eliminates stored AWS credentials
* IAM roles provide least-privilege access
* Security groups restrict network traffic
* Private service discovery network


**Scalability:**
* Easy to add more worker nodes
* Kubernetes handles load distribution
* Horizontal pod autoscaling possible


**Maintainability:**
* Service discovery eliminates IP management
* Infrastructure as Code (Terraform)
* Automated deployments reduce manual errors
* Comprehensive monitoring and alerting


---


## What You Will Learn

By completing this guide, you will gain hands-on experience with:

* Terraform infrastructure provisioning
* Kubernetes cluster administration
* Jenkins pipeline creation and management
* SonarQube code quality analysis
* Nexus artifact repository management
* Docker containerization
* AWS security best practices
* Service discovery implementation
* Monitoring and observability


---


## Expected Outcomes

**After completion, you will have:**

* Fully functional CI/CD pipeline
* Deployed Java application on Kubernetes
* Automated code quality checks
* Container security scanning
* Artifact version management
* Real-time monitoring dashboards
* Complete infrastructure as code


---


## Architecture Verification

**In Step 10, you will verify:**

* All 5 instances running and accessible
* Kubernetes cluster with 3 nodes (1 master, 2 workers)
* Jenkins executing all 11 pipeline stages successfully
* SonarQube showing code analysis results
* Nexus containing versioned artifacts
* Docker Hub containing application images
* Application accessible via web browser
* Prometheus collecting metrics
* Grafana displaying dashboards


---


## Next Steps

Now that you understand the architecture, proceed to:

**Step 2: AWS Account Setup** (`02-aws-setup.md`)

You will configure your AWS account and create necessary resources.


---


**Key Takeaway:** This architecture balances cost, performance, and best practices. Each component has a specific purpose in the CI/CD workflow.
