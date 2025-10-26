# Infrastructure & Application Compatibility Analysis

## 🚨 CRITICAL ISSUES IDENTIFIED

After cross-referencing the **proven working application** from the reference repository with our **custom Terraform infrastructure**, here are the compatibility issues that **MUST** be fixed:

---

## 1. ❌ Java Version Mismatch

### Issue:
- **pom.xml** specifies: `<java.version>11</java.version>`
- **Jenkinsfile** requests: `jdk 'java17'`
- **Dockerfile** uses: `FROM openjdk:17-alpine`
- **Setup script** installs: `openjdk-17-jre`

### Impact:
Maven build will **FAIL** because the application code is Java 11 but runtime expects Java 17.

### Solution:
**Option A - Use Java 17 (Recommended):**
```xml
<!-- Update pom.xml -->
<java.version>17</java.version>
```

**Option B - Use Java 11:**
```dockerfile
# Update Dockerfile
FROM openjdk:11-alpine
```
```groovy
// Update Jenkinsfile
jdk 'java11'
```

**✅ RECOMMENDATION:** Use Java 17 (modern, better performance, update pom.xml only)

---

## 2. ❌ Hardcoded Nexus URL in pom.xml

### Issue:
```xml
<distributionManagement>
  <repository>
    <id>maven-releases</id>
    <url>http://54.226.125.170:8081/repository/maven-releases/</url>
  </repository>
</distributionManagement>
```

This is **someone else's Nexus server** - it won't exist in your infrastructure!

### Impact:
Maven deploy stage will **FAIL** trying to reach non-existent IP.

### Solution:
**Option A - Use Service Discovery (Best for Learning):**
```xml
<url>http://nexus-sonarqube.ultimate-cicd-devops.local:8081/repository/maven-releases/</url>
```

**Option B - Use Terraform Output (Production-like):**
```xml
<!-- Use environment variable in Jenkins -->
<url>${env.NEXUS_URL}/repository/maven-releases/</url>
```

**Option C - Comment Out (Simplest for Testing):**
```xml
<!-- <distributionManagement>
  ...commented out for now...
</distributionManagement> -->
```

**✅ RECOMMENDATION:** Use service discovery DNS (shows you how it works)

---

## 3. ❌ Docker Image Reference in Kubernetes

### Issue:
```yaml
image: bettysami/boardgame:latest
```

This is **someone else's Docker Hub account** - you need your own!

### Impact:
Kubernetes will pull **their old image**, not your freshly built one.

### Solution:
**Option A - Use Docker Hub (Easiest):**
```yaml
image: YOUR_DOCKERHUB_USERNAME/boardgame:latest
```

**Option B - Use AWS ECR (Production-like):**
```yaml
image: 123456789012.dkr.ecr.us-east-1.amazonaws.com/boardgame:latest
```

**Option C - Use K8s Local Registry:**
```yaml
image: localhost:5000/boardgame:latest
```

**✅ RECOMMENDATION:** Start with Docker Hub, migrate to ECR later

---

## 4. ❌ Incomplete Jenkinsfile

### Issue:
Current Jenkinsfile only has:
```groovy
stages {
    stage('Compile') { ... }
    stage('Testing') { ... }
    stage('Building The Project') { ... }
}
```

**Missing critical stages:**
- ❌ SonarQube Code Analysis
- ❌ Docker Image Build
- ❌ Docker Push to Registry
- ❌ Trivy Security Scan
- ❌ Deploy to Kubernetes

### Impact:
Pipeline **won't deploy** the application - it only builds the JAR file!

### Solution:
See `JENKINSFILE-COMPLETE.md` for full pipeline (created separately).

---

## 5. ⚠️ Maven Version Configuration

### Issue:
- **Jenkinsfile** requests: `maven 'maven3.6'`
- This is a **Jenkins Global Tool Configuration** name reference
- Won't exist by default on fresh Jenkins installation

### Impact:
Pipeline will **FAIL** with "maven3.6 tool not found"

### Solution:
After Jenkins installation, configure in **Manage Jenkins → Global Tool Configuration → Maven**:
- Name: `maven3.6` (or update Jenkinsfile to match actual name)
- Install automatically: Maven 3.9.6 (latest stable)

**OR** update Jenkinsfile to use auto-install:
```groovy
tools {
    jdk 'java17'
    maven 'Maven 3.9.6'  // Use actual version name
}
```

---

## 6. ⚠️ Service Discovery vs Hardcoded IPs

### Our Enhancement:
We added **AWS Cloud Map service discovery** which the original doesn't have:
- ✅ `jenkins-k8s-master.ultimate-cicd-devops.local`
- ✅ `nexus-sonarqube.ultimate-cicd-devops.local`
- ✅ `k8s-worker-1.ultimate-cicd-devops.local`

### What This Means:
Instead of hardcoding IPs everywhere, you can use DNS names!

**Example in Jenkins:**
```groovy
environment {
    SONAR_URL = "http://nexus-sonarqube.ultimate-cicd-devops.local:9000"
    NEXUS_URL = "http://nexus-sonarqube.ultimate-cicd-devops.local:8081"
}
```

This works **inside AWS VPC** (between EC2 instances).

---

## ✅ WHAT'S ALREADY COMPATIBLE

Good news! These things are **already aligned**:

1. ✅ **Application Port**: App uses 8080, K8s deployment expects 8080
2. ✅ **Spring Boot Version**: 2.5.6 is stable and compatible
3. ✅ **H2 Database**: Embedded, no external DB needed
4. ✅ **Resource Limits**: K8s requests (256Mi/250m) fit in t3.medium instances
5. ✅ **Ubuntu Base**: All scripts use Ubuntu (matches proven setup)
6. ✅ **Docker Compose**: Nexus/SonarQube use same Docker Compose approach
7. ✅ **Calico Network**: K8s networking matches proven setup

---

## 📋 PRE-DEPLOYMENT CHECKLIST

Before running `terraform apply`, ensure:

### Infrastructure Configuration:
- [ ] `terraform.auto.tfvars` has correct `key_name`
- [ ] SSH key file (`.pem`) is in your local folder
- [ ] `allowed_cidr` includes your IP for SSH access
- [ ] `github_org` and `github_repo` are correct (for OIDC)

### Application Configuration:
- [ ] Update `pom.xml` Java version to 17
- [ ] Update `pom.xml` Nexus URLs (or comment out)
- [ ] Update `kubernetes/deployment-service.yaml` image reference
- [ ] Create complete Jenkinsfile with all stages
- [ ] Create Docker Hub account (or configure ECR)

### Jenkins Configuration (Post-Deployment):
- [ ] Configure Java 17 in Global Tool Configuration
- [ ] Configure Maven 3.9.6 in Global Tool Configuration
- [ ] Add Docker Hub credentials
- [ ] Add SonarQube token
- [ ] Install required plugins:
  - SonarQube Scanner
  - Docker Pipeline
  - Kubernetes CLI
  - Nexus Artifact Uploader

---

## 🎯 RECOMMENDED FIX ORDER

### Phase 1 - Critical Fixes (Do BEFORE terraform apply):
1. **Fix pom.xml**: Update Java version to 17
2. **Fix pom.xml**: Update or comment out Nexus URLs
3. **Fix deployment-service.yaml**: Change image to your Docker Hub username
4. **Create complete Jenkinsfile**: Add missing pipeline stages

### Phase 2 - Infrastructure Deployment:
1. Run `terraform init`
2. Run `terraform plan` (review outputs)
3. Run `terraform apply`
4. Save outputs (IPs, URLs, DNS names)

### Phase 3 - Post-Deployment Configuration:
1. SSH to Jenkins master: `terraform output ssh_commands`
2. Get Jenkins admin password: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
3. Access Jenkins UI, install plugins, configure tools
4. Initialize K8s master: `/home/ubuntu/init-k8s-master.sh`
5. Join worker nodes to cluster
6. Create Jenkins pipeline with your Jenkinsfile
7. Configure SonarQube admin password (default: admin/admin)

### Phase 4 - Test Pipeline:
1. Trigger Jenkins build
2. Verify each stage passes
3. Check SonarQube analysis
4. Verify Docker image pushed
5. Check K8s deployment: `kubectl get pods`
6. Access app: `kubectl get svc boardgame-ssvc`

---

## 🔧 TESTING THE FIXES

### Test 1 - Maven Build Locally:
```bash
cd app/
./mvnw clean package
# Should succeed with Java 17
```

### Test 2 - Docker Build Locally:
```bash
cd app/
docker build -t boardgame:test .
docker run -p 8080:8080 boardgame:test
# Access http://localhost:8080
```

### Test 3 - K8s Manifest Validation:
```bash
kubectl apply --dry-run=client -f kubernetes/deployment-service.yaml
# Should show no errors
```

---

## 📚 REFERENCE ARCHITECTURE

The **proven working setup** has this exact configuration:

| Component | Version/Config |
|-----------|---------------|
| Java | OpenJDK 17 |
| Maven | 3.6+ |
| Spring Boot | 2.5.6 |
| Kubernetes | 1.28 |
| Docker | Latest CE |
| Jenkins | Latest LTS |
| SonarQube | Docker latest |
| Nexus | Docker latest |

**Our infrastructure matches this** ✅

The only changes needed are:
1. Fix Java version in pom.xml
2. Fix hardcoded URLs (Nexus, Docker image)
3. Complete the Jenkinsfile
4. Configure Jenkins tools after deployment

---

## 🚀 NEXT STEPS

1. Read this document thoroughly
2. Review `SETUP-GUIDE.md` (being created) for exact commands
3. Make the Phase 1 fixes to application files
4. Proceed with terraform deployment
5. Follow Phase 3 post-deployment steps
6. Test the pipeline end-to-end

---

## ⚠️ COMMON PITFALLS TO AVOID

1. **DON'T** skip updating pom.xml Java version → Maven build will fail
2. **DON'T** forget to update Docker image name → K8s will pull wrong image
3. **DON'T** forget to initialize K8s master → Workers can't join
4. **DON'T** forget Jenkins tool configuration → Pipeline will fail
5. **DON'T** skip joining workers to K8s → No deployment targets
6. **DON'T** forget to configure credentials → Can't push to registries

---

**Last Updated:** Cross-referenced with proven application on October 25, 2025
**Status:** Ready for fixes before deployment
