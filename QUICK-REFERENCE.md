# Quick Reference Card

**Complete CI/CD Pipeline Setup**


## Infrastructure Overview

```
5 EC2 Instances (t3.medium):
├── Jenkins + K8s Master (combined)
├── K8s Worker 1
├── K8s Worker 2  
├── Nexus + SonarQube (combined)
└── Prometheus + Grafana (combined)
```


## Service URLs

After deployment, access services at:

```
Jenkins:     http://<JENKINS_IP>:8080
SonarQube:   http://<NEXUS_SONARQUBE_IP>:9000
Nexus:       http://<NEXUS_SONARQUBE_IP>:8081
Prometheus:  http://<PROMETHEUS_IP>:9090
Grafana:     http://<PROMETHEUS_IP>:3000
Application: http://<WORKER_IP>:<NODE_PORT>
```


## Service Discovery DNS (Internal)

```
jenkins-k8s-master.ultimate-cicd-devops.local
k8s-worker-1.ultimate-cicd-devops.local
k8s-worker-2.ultimate-cicd-devops.local
nexus-sonarqube.ultimate-cicd-devops.local
prometheus-grafana.ultimate-cicd-devops.local
```


## Default Credentials

**AWS:**
- Region: us-east-1
- SSH Key: k8s-pipeline-key.pem

**Jenkins:**
- Username: admin
- Initial Password: (from /var/lib/jenkins/secrets/initialAdminPassword)
- Set your own during setup

**SonarQube:**
- Default: admin / admin
- Change on first login

**Nexus:**
- Initial: admin / (from docker exec nexus cat /nexus-data/admin.password)
- Set to: admin / admin123

**Grafana:**
- Default: admin / admin
- Change on first login

**Application (Boardgame):**
- User 1: bugs / bunny
- User 2: daffy / duck


## Quick Commands

**Deploy infrastructure:**
```bash
cd ~/Documents/PROJECTS/ec2-k8s
terraform init
terraform apply
```

**Get outputs:**
```bash
terraform output
```

**SSH to instances:**
```bash
ssh -i k8s-pipeline-key.pem ubuntu@<PUBLIC_IP>
```

**Check K8s cluster:**
```bash
kubectl get nodes
kubectl get pods -n webapps
kubectl get svc -n webapps
```

**Destroy infrastructure:**
```bash
terraform destroy
```


## Jenkins Tool Names (for Jenkinsfile)

```
JDK: jdk17
Maven: maven3.6
Docker: docker
SonarQube Scanner: sonar-scanner
```


## Jenkins Credential IDs (for Jenkinsfile)

```
Docker Hub: docker-cred
GitHub: git-cred
Kubernetes: k8-cred
SonarQube: sonar-token
```


## Pipeline Stages (11 Total)

```
1.  Git Checkout
2.  Compile
3.  Unit Tests
4.  SonarQube Analysis
5.  Quality Gate
6.  Build
7.  Publish to Nexus
8.  Build Docker Image
9.  Trivy Scan
10. Push to Docker Hub
11. Deploy to Kubernetes
```


## Repository URLs

**Nexus Maven Repositories:**
```
Releases:  http://nexus-sonarqube.ultimate-cicd-devops.local:8081/repository/maven-releases/
Snapshots: http://nexus-sonarqube.ultimate-cicd-devops.local:8081/repository/maven-snapshots/
```


## Docker Images

**Initial deployment:**
```
bettysami/boardgame:latest (proven working image)
```

**After pipeline build:**
```
temitayocharles/boardgame:latest (your built image)
```


## Important Files

**Terraform:**
- terraform.auto.tfvars (your config - gitignored)
- terraform.auto.tfvars.example (template)

**Application:**
- app/pom.xml (Maven config)
- app/Dockerfile (Docker build)

**CI/CD:**
- ci-cd/Jenkinsfile (pipeline definition)
- ci-cd/sonar-project.properties (SonarQube config)

**Kubernetes:**
- kubernetes/deployment-service.yaml (K8s manifest)

**Guides:**
- guides/00-START-HERE.md (navigation)
- guides/01-10 (step-by-step instructions)


## Time Estimates

```
Step 1: Architecture           5 min (reading)
Step 2: AWS Setup             15 min
Step 3: Local Setup           10 min
Step 4: Terraform Deploy      20 min
Step 5: Kubernetes Setup      20 min
Step 6: Jenkins Config        40 min (most detailed)
Step 7: SonarQube Setup       15 min
Step 8: Nexus Setup           20 min
Step 9: Pipeline Creation     30 min (first build)
Step 10: Verification         25 min

Total: ~3 hours for complete setup
```


## Troubleshooting Quick Tips

**Service not accessible:**
```bash
# Check security group allows your IP
# Check service is running:
sudo systemctl status <service>
docker ps
```

**Kubernetes pods not running:**
```bash
kubectl get pods -n webapps
kubectl describe pod <pod-name> -n webapps
kubectl logs <pod-name> -n webapps
```

**Pipeline failing:**
```
- Check Jenkins console output
- Verify all credentials configured
- Ensure services are accessible via service discovery
- Review specific stage error messages
```

**DNS not resolving:**
```bash
# Wait 30-60 seconds after instance starts
# Check Cloud Map in AWS Console
# Test from instance: ping <service>.ultimate-cicd-devops.local
```


## Cost Optimization

**Running all 5 instances:**
- ~$0.50-0.60/hour
- ~$12-15/day if left running

**Recommendation:**
```bash
# When done for the day:
terraform destroy

# Next session:
terraform apply
# Reconfigure services (or use backups)
```


## Getting Help

**Check these in order:**

1. Guide troubleshooting sections
2. Console output / logs
3. AWS Console (verify resources)
4. Terraform state: `terraform show`
5. Service logs: `sudo journalctl -u <service>`


## Success Indicators

**Infrastructure ready:**
- All 5 instances running
- Security groups attached
- Service discovery DNS resolving

**Kubernetes ready:**
- 3 nodes Ready
- All kube-system pods Running
- Application namespace created

**Jenkins ready:**
- Accessible on port 8080
- All plugins installed
- All tools configured
- All credentials added

**Pipeline successful:**
- All 11 stages green
- Artifacts in Nexus
- Analysis in SonarQube
- Image in Docker Hub
- App running in K8s


## Next Steps After Completion

**Expand your knowledge:**

1. Add more pipeline stages (integration tests, etc.)
2. Implement Ingress controller
3. Set up TLS/SSL certificates
4. Configure autoscaling
5. Add monitoring alerts
6. Implement blue-green deployments


---


**Save this reference card for quick lookups during setup!**
