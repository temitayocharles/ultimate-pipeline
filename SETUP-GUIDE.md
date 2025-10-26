# Complete Setup Guide - Ultimate CI/CD Pipeline

**This guide ensures the proven application works with your custom Terraform infrastructure.**

> 📌 **IMPORTANT**: All compatibility issues have been fixed in this repository. Follow this guide exactly for a working deployment.

---

## 🎯 Overview

This guide walks you through deploying a complete CI/CD pipeline that's been **tested and proven to work**. The application code is from a working reference, and the infrastructure has been enhanced with service discovery and OIDC.

**What you'll build:**
- 5 EC2 instances (Jenkins+K8s master, 2 workers, tools, monitoring)
- Full CI/CD pipeline (Git → Jenkins → SonarQube → Docker → K8s)
- Monitoring with Prometheus & Grafana
- Service discovery with AWS Cloud Map
- Optional OIDC for GitHub Actions

**Estimated time:** 45-60 minutes  
**Cost per 4-hour session:** ~$0.67 (with terraform destroy)

---

## 📋 Prerequisites Checklist

Before starting, ensure you have:

- [ ] **AWS Account** with admin or power user access
- [ ] **AWS CLI** installed and configured (`aws configure`)
- [ ] **Terraform** >= 1.0 installed (`terraform version`)
- [ ] **SSH key pair** created in AWS EC2 console (e.g., `k8s-pipeline-key`)
- [ ] **SSH key file** downloaded to project root (e.g., `k8s-pipeline-key.pem`)
- [ ] **Git** configured with your GitHub credentials
- [ ] **Docker Hub account** (free tier) - https://hub.docker.com/signup
- [ ] **Text editor** for configuration files

---

## 🚀 Phase 1: Pre-Deployment Configuration

### Step 1.1: Configure Terraform Variables

Edit `terraform/terraform.auto.tfvars`:

```hcl
# AWS Configuration
aws_config = {
  region = "us-east-1"
}

# SSH Configuration - CRITICAL!
ssh_config = {
  key_name     = "k8s-pipeline-key"  # ⚠️ Your actual AWS key pair name
  allowed_cidr = ["YOUR_IP/32"]      # ⚠️ Run: curl ifconfig.me
}

# Instance Types (t3.medium recommended for cost/performance)
instance_types = {
  jenkins_k8s_master = "t3.medium"
  k8s_worker         = "t3.medium"
  nexus_sonarqube    = "t3.medium"
  monitoring         = "t3.medium"
}

# Project Configuration
project_config = {
  name        = "ultimate-cicd-devops"
  environment = "learning"
}

# Feature Flags - Start with all enabled
feature_flags = {
  enable_monitoring_instance = true
  enable_tools_instance      = true
  enable_worker_2            = true
}

# OIDC Configuration (optional for GitHub Actions)
oidc_config = {
  github_org         = "temitayocharles"        # ⚠️ Your GitHub username
  github_repo        = "ultimate-pipeline"      # ⚠️ Your repo name
  enable_github_oidc = false  # Set true after understanding OIDC
}
```

### Step 1.2: Set SSH Key Permissions

```bash
cd terraform/
chmod 400 ../k8s-pipeline-key.pem
```

### Step 1.3: Verify Application Files

These have been fixed for compatibility:

✅ **app/pom.xml** - Java 17, service discovery URLs  
✅ **kubernetes/deployment-service.yaml** - Your Docker Hub username  
✅ **ci-cd/Jenkinsfile** - Complete pipeline with all stages  

**Verify Docker Hub username:**
```bash
grep "image:" kubernetes/deployment-service.yaml
# Should show: temitayocharles/boardgame:latest
```

---

## 🏗️ Phase 2: Deploy Infrastructure

### Step 2.1: Initialize Terraform

```bash
cd terraform/
terraform init
```

**Expected output:**
```
Initializing provider plugins...
- Installing hashicorp/aws v~> 5.0...

Terraform has been successfully initialized!
```

### Step 2.2: Review Deployment Plan

```bash
terraform plan
```

**Verify:**
- [ ] 5 EC2 instances planned
- [ ] Security groups configured
- [ ] Service discovery resources created
- [ ] IAM roles and instance profiles created

### Step 2.3: Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when prompted.

**Deployment time:** ~3-5 minutes

### Step 2.4: Save Outputs

```bash
terraform output > ../infrastructure-outputs.txt
cat ../infrastructure-outputs.txt
```

**You should see:**
- Jenkins URL
- All public IPs
- SSH commands
- Service discovery DNS names
- SonarQube & Nexus URLs
- Monitoring URLs

---

## ⚙️ Phase 3: Configure Services

### Step 3.1: Initialize Kubernetes Master

**Wait 5 minutes** after terraform apply for cloud-init to complete.

```bash
# SSH to Jenkins/K8s master (from terraform output)
ssh -i ../k8s-pipeline-key.pem ubuntu@<MASTER_PUBLIC_IP>

# Check cloud-init status
cloud-init status

# When complete, initialize K8s
/home/ubuntu/init-k8s-master.sh
```

**This script will:**
- Initialize kubeadm
- Set up kubectl config
- Install Calico network plugin
- Print join command for workers

**Save the join command!** It looks like:
```bash
kubeadm join 172.31.x.x:6443 --token abc123... --discovery-token-ca-cert-hash sha256:def456...
```

### Step 3.2: Join Worker Nodes

**For each worker:**

```bash
# SSH to worker 1
ssh -i ../k8s-pipeline-key.pem ubuntu@<WORKER1_PUBLIC_IP>

# Paste the join command from master
sudo kubeadm join 172.31.x.x:6443 --token abc123... --discovery-token-ca-cert-hash sha256:def456...

# Repeat for worker 2
ssh -i ../k8s-pipeline-key.pem ubuntu@<WORKER2_PUBLIC_IP>
sudo kubeadm join ...
```

**Verify from master:**
```bash
kubectl get nodes
```

**Expected output:**
```
NAME                 STATUS   ROLES           AGE   VERSION
jenkins-k8s-master   Ready    control-plane   5m    v1.28.x
k8s-worker-1         Ready    <none>          2m    v1.28.x
k8s-worker-2         Ready    <none>          1m    v1.28.x
```

### Step 3.3: Configure Jenkins

**Get Jenkins admin password:**
```bash
# On Jenkins master
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

**Access Jenkins UI:**
```bash
# From terraform outputs
http://<JENKINS_PUBLIC_IP>:8080
```

**Setup steps:**

1. **Unlock Jenkins** - Paste admin password
2. **Install Plugins** - Select "Install suggested plugins"
3. **Additional Required Plugins:**
   - Manage Jenkins → Plugins → Available
   - Search and install:
     - ✅ SonarQube Scanner
     - ✅ Docker Pipeline
     - ✅ Kubernetes CLI
     - ✅ Nexus Artifact Uploader
     - ✅ Config File Provider

4. **Configure Global Tools** - Manage Jenkins → Tools:

   **JDK:**
   - Name: `java17`
   - JAVA_HOME: `/usr/lib/jvm/java-17-openjdk-amd64`
   
   **Maven:**
   - Name: `maven3.6`
   - Install automatically: Maven 3.9.6

5. **Configure Credentials** - Manage Jenkins → Credentials → System → Global:

   **Docker Hub:**
   - Kind: Username with password
   - ID: `docker-hub-creds`
   - Username: Your Docker Hub username
   - Password: Your Docker Hub password/token

   **Kubernetes:**
   - Kind: Secret file
   - ID: `k8s-creds`
   - File: Upload `/home/ubuntu/.kube/config` from master

6. **Configure SonarQube Server** - Manage Jenkins → System:
   - Name: `sonar-server`
   - Server URL: `http://nexus-sonarqube.ultimate-cicd-devops.local:9000`
   - Token: (create in SonarQube, see Step 3.4)

7. **Configure Maven Settings** - Manage Jenkins → Managed files:
   - Add new config → Global Maven settings.xml
   - ID: `maven-settings`
   - Content:
   ```xml
   <settings>
     <servers>
       <server>
         <id>maven-releases</id>
         <username>admin</username>
         <password>admin123</password>
       </server>
       <server>
         <id>maven-snapshots</id>
         <username>admin</username>
         <password>admin123</password>
       </server>
     </servers>
   </settings>
   ```

### Step 3.4: Configure SonarQube

**Access SonarQube:**
```bash
http://<NEXUS_SONARQUBE_PUBLIC_IP>:9000
```

**Default credentials:** `admin` / `admin`  
**Change password when prompted!**

**Create token for Jenkins:**
1. Administration → Security → Users
2. Click tokens icon for admin user
3. Generate token: `jenkins-token`
4. Copy token value
5. Add to Jenkins credentials:
   - Kind: Secret text
   - ID: `sonar-token`
   - Secret: Paste token

### Step 3.5: Configure Nexus

**Access Nexus:**
```bash
http://<NEXUS_SONARQUBE_PUBLIC_IP>:8081
```

**Get admin password:**
```bash
ssh -i k8s-pipeline-key.pem ubuntu@<NEXUS_SONARQUBE_PUBLIC_IP>
docker exec -it <nexus-container-id> cat /nexus-data/admin.password
```

**Login and configure:**
1. Username: `admin`
2. Password: From above
3. Change admin password (use `admin123` to match Maven settings)
4. Enable anonymous access (optional)
5. Create repositories (already exist by default):
   - `maven-releases`
   - `maven-snapshots`

---

## 🚢 Phase 4: Deploy Application

### Step 4.1: Create Jenkins Pipeline

1. **New Item** → Enter name: `boardgame-pipeline`
2. **Select:** Pipeline
3. **Pipeline Definition:** Pipeline script from SCM
4. **SCM:** Git
5. **Repository URL:** `https://github.com/temitayocharles/ultimate-pipeline.git`
6. **Branch:** `*/main`
7. **Script Path:** `ci-cd/Jenkinsfile`
8. **Save**

### Step 4.2: Run Initial Build

1. Click **Build Now**
2. Monitor console output
3. Watch each stage complete:
   - ✅ Git Checkout
   - ✅ Compile
   - ✅ Unit Tests
   - ✅ SonarQube Analysis
   - ✅ Quality Gate
   - ✅ Build Application
   - ✅ Publish to Nexus
   - ✅ Build Docker Image
   - ✅ Trivy Image Scan
   - ✅ Push Docker Image
   - ✅ Deploy to Kubernetes
   - ✅ Verify Deployment

**First build may take 5-10 minutes** (Maven downloads dependencies).

### Step 4.3: Verify Deployment

**Check Kubernetes:**
```bash
# SSH to master
ssh -i k8s-pipeline-key.pem ubuntu@<MASTER_PUBLIC_IP>

# Check pods
kubectl get pods
# Should show: boardgame-deployment-xxx (2 replicas)

# Check service
kubectl get svc boardgame-ssvc
# Note the LoadBalancer or NodePort
```

**Access Application:**
```bash
# Get service URL
kubectl get svc boardgame-ssvc

# If LoadBalancer (on AWS)
http://<EXTERNAL-IP>

# If NodePort (local K8s)
http://<WORKER_IP>:<NODE_PORT>
```

**Test credentials:**
- User: `bugs` / Password: `bunny` (user role)
- User: `daffy` / Password: `duck` (manager role)

---

## 📊 Phase 5: Verify Monitoring

### Prometheus

**Access:**
```bash
http://<MONITORING_PUBLIC_IP>:9090
```

**Verify targets:**
- Status → Targets
- Should see: node-exporter, prometheus itself

### Grafana

**Access:**
```bash
http://<MONITORING_PUBLIC_IP>:3000
```

**Default credentials:** `admin` / `admin`

**Add Prometheus datasource:**
1. Configuration → Data Sources
2. Add Prometheus
3. URL: `http://localhost:9090`
4. Save & Test

**Import dashboards:**
- Node Exporter: Dashboard ID 1860
- Kubernetes Cluster: Dashboard ID 6417

---

## ✅ Verification Checklist

After deployment, verify everything works:

### Infrastructure
- [ ] All 5 EC2 instances running
- [ ] Security groups allow required ports
- [ ] Service discovery DNS resolves (test from any instance)
- [ ] IAM instance profiles attached

### Kubernetes
- [ ] Master node initialized
- [ ] 2 worker nodes joined and Ready
- [ ] Calico network plugin running
- [ ] kubectl works from master

### Jenkins
- [ ] UI accessible
- [ ] All plugins installed
- [ ] Tools configured (Java, Maven)
- [ ] Credentials added (Docker Hub, K8s, SonarQube)
- [ ] Pipeline created from Git

### Application Pipeline
- [ ] Build succeeds (green checkmark)
- [ ] SonarQube analysis completes
- [ ] Docker image pushed to Docker Hub
- [ ] Kubernetes deployment successful
- [ ] Application accessible via browser
- [ ] Test login works

### Monitoring
- [ ] Prometheus collecting metrics
- [ ] Grafana dashboards displaying data
- [ ] Node exporter reporting system metrics

### SonarQube & Nexus
- [ ] SonarQube shows code analysis
- [ ] Nexus contains deployed artifacts

---

## 🐛 Troubleshooting

### Issue: Terraform apply fails with "UnauthorizedOperation"

**Fix:** Check AWS credentials
```bash
aws sts get-caller-identity
```

### Issue: Can't SSH to instances

**Fix:** Check security group and key permissions
```bash
chmod 400 k8s-pipeline-key.pem
# Verify allowed_cidr in tfvars matches your IP
curl ifconfig.me
```

### Issue: K8s nodes not joining

**Fix:** Check connectivity and token
```bash
# On master, create new token
kubeadm token create --print-join-command

# On worker, ensure containerd is running
sudo systemctl status containerd
```

### Issue: Jenkins build fails at Maven stage

**Fix:** Verify tool configuration
```bash
# Manage Jenkins → Tools
# Ensure java17 and maven3.6 are configured
```

### Issue: Docker push fails

**Fix:** Verify Docker Hub credentials
```bash
# Re-add credentials with correct username/password
# Ensure docker-hub-creds ID matches Jenkinsfile
```

### Issue: SonarQube analysis fails

**Fix:** Check SonarQube is running
```bash
ssh ubuntu@<NEXUS_IP>
docker ps | grep sonar
# Access http://<IP>:9000 to verify
```

### Issue: K8s deployment times out

**Fix:** Check Docker image exists
```bash
# Verify on Docker Hub or:
docker pull temitayocharles/boardgame:latest
```

### Issue: Application not accessible

**Fix:** Check service and pods
```bash
kubectl get svc boardgame-ssvc
kubectl get pods -l app=boardgame
kubectl logs <pod-name>
```

---

## 💰 Cost Management

**After Learning Session:**

```bash
cd terraform/
terraform destroy
```

Type `yes` to confirm.

**This removes all AWS resources and stops billing!**

**Cost Optimization Options:**

**Minimal setup** (1 instance, ~$15/month):
```hcl
feature_flags = {
  enable_monitoring_instance = false
  enable_tools_instance      = false
  enable_worker_2            = false
}
```

**Medium setup** (3 instances, ~$100/month):
```hcl
feature_flags = {
  enable_monitoring_instance = false
  enable_tools_instance      = true
  enable_worker_2            = false
}
```

---

## 🎓 Next Steps

Now that everything works:

1. **Customize the application** - Modify Java code, commit, watch pipeline deploy
2. **Add more K8s features** - Try Ingress, ConfigMaps, Secrets
3. **Enhance monitoring** - Add custom Prometheus exporters
4. **Try OIDC** - Enable GitHub Actions for automated deployments
5. **Migrate to ECR** - Use AWS ECR instead of Docker Hub
6. **Add more tests** - Integration tests, security scans
7. **Implement GitOps** - Use ArgoCD or Flux

---

## 📚 Reference Commands

**Quick SSH:**
```bash
# Get all SSH commands
terraform output ssh_commands

# SSH to Jenkins/K8s master
ssh -i k8s-pipeline-key.pem ubuntu@$(terraform output -raw jenkins_k8s_master_public_ip)
```

**Check Service Discovery:**
```bash
# From any EC2 instance
nslookup jenkins-k8s-master.ultimate-cicd-devops.local
nslookup nexus-sonarqube.ultimate-cicd-devops.local
```

**Jenkins Restart:**
```bash
ssh ubuntu@<MASTER_IP>
sudo systemctl restart jenkins
```

**K8s Quick Commands:**
```bash
kubectl get all
kubectl get pods -A
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl delete pod <pod-name>  # Will recreate
```

**Docker Commands (on Jenkins master):**
```bash
docker images
docker ps
docker logs <container-id>
```

---

## 📞 Support

- **Terraform Errors:** Check [ARCHITECTURE.md](ARCHITECTURE.md)
- **Application Issues:** Check [COMPATIBILITY.md](COMPATIBILITY.md)
- **Quick Reference:** Check [QUICKREF.md](QUICKREF.md)

---

**Congratulations! 🎉**

You now have a complete, production-grade CI/CD pipeline running on AWS!

**Remember:** Run `terraform destroy` after each learning session to avoid unnecessary costs.

---

**Last Updated:** October 25, 2025  
**Status:** Tested and working ✅
