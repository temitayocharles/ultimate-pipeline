# Step 10: Verification and Testing

**Duration:** 20-25 minutes

**Goal:** Comprehensive verification of entire CI/CD pipeline and monitoring setup


---


## What You Will Do

* Verify all infrastructure components
* Test complete CI/CD workflow end-to-end
* Configure and verify monitoring (Prometheus, Grafana)
* Test application functionality
* Perform security verification
* Document your deployment
* Clean up resources


---


## Task 1: Infrastructure Health Check

Verify all AWS resources are running correctly.


### Instructions

**1.1** Open AWS Console in browser:

```
https://console.aws.amazon.com/ec2
```


**1.2** Navigate to EC2 → Instances (running).


**1.3** Verify all 5 instances are running:

```
Name                      State     Type        Public IP
jenkins-k8s-master       running   t3.medium   <IP>
k8s-worker-1             running   t3.medium   <IP>
k8s-worker-2             running   t3.medium   <IP>
nexus-sonarqube          running   t3.medium   <IP>
prometheus-grafana       running   t3.medium   <IP>
```


**1.4** Note the "Instance Age" - should match when you ran terraform apply.


**1.5** Check security groups are attached to each instance.


### Verification

**All 5 instances:** Running, healthy, with security groups attached.


---


## Task 2: Kubernetes Cluster Health

Verify Kubernetes cluster is healthy.


### Instructions

**2.1** SSH to Jenkins/K8s master:

```bash
ssh -i k8s-pipeline-key.pem ubuntu@<JENKINS_MASTER_PUBLIC_IP>
```


**2.2** Check all nodes:

```bash
kubectl get nodes
```


**Expected output:**

```
NAME                 STATUS   ROLES           AGE   VERSION
jenkins-k8s-master   Ready    control-plane   Xh    v1.28.1
k8s-worker-1         Ready    <none>          Xh    v1.28.1
k8s-worker-2         Ready    <none>          Xh    v1.28.1
```


**All nodes should be Ready.**


**2.3** Check system pods:

```bash
kubectl get pods -n kube-system
```


**Expected output:** All pods Running.

```
NAME                                        READY   STATUS    RESTARTS   AGE
calico-kube-controllers-xxxxx               1/1     Running   0          Xh
calico-node-xxxxx                           1/1     Running   0          Xh
calico-node-xxxxx                           1/1     Running   0          Xh
calico-node-xxxxx                           1/1     Running   0          Xh
coredns-xxxxx                               1/1     Running   0          Xh
coredns-xxxxx                               1/1     Running   0          Xh
etcd-jenkins-k8s-master                     1/1     Running   0          Xh
kube-apiserver-jenkins-k8s-master           1/1     Running   0          Xh
kube-controller-manager-jenkins-k8s-master  1/1     Running   0          Xh
kube-proxy-xxxxx                            1/1     Running   0          Xh
kube-proxy-xxxxx                            1/1     Running   0          Xh
kube-proxy-xxxxx                            1/1     Running   0          Xh
kube-scheduler-jenkins-k8s-master           1/1     Running   0          Xh
```


**2.4** Check application pods:

```bash
kubectl get pods -n webapps
```


**Expected output:**

```
NAME                         READY   STATUS    RESTARTS   AGE
boardgame-xxxxxxxxxx-xxxxx   1/1     Running   0          Xm
boardgame-xxxxxxxxxx-xxxxx   1/1     Running   0          Xm
```


**2.5** Check resource usage:

```bash
kubectl top nodes
```


**Expected output:**

```
NAME                 CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
jenkins-k8s-master   400m         20%    2500Mi          65%
k8s-worker-1         200m         10%    1800Mi          47%
k8s-worker-2         150m         7%     1500Mi          39%
```


### Verification

**Kubernetes cluster:** 3 nodes Ready, all system pods Running, application pods healthy.


---


## Task 3: Service Discovery Verification

Test AWS Cloud Map service discovery.


### Instructions

**3.1** Still SSH'd to Jenkins master, test DNS resolution:

```bash
# Jenkins Master
ping -c 2 jenkins-k8s-master.ultimate-cicd-devops.local

# Workers
ping -c 2 k8s-worker-1.ultimate-cicd-devops.local
ping -c 2 k8s-worker-2.ultimate-cicd-devops.local

# Nexus/SonarQube
ping -c 2 nexus-sonarqube.ultimate-cicd-devops.local

# Prometheus/Grafana
ping -c 2 prometheus-grafana.ultimate-cicd-devops.local
```


**All should resolve to private IPs (10.x.x.x).**


**3.2** Test HTTP connectivity:

```bash
# SonarQube
curl -I http://nexus-sonarqube.ultimate-cicd-devops.local:9000

# Nexus
curl -I http://nexus-sonarqube.ultimate-cicd-devops.local:8081

# Prometheus
curl -I http://prometheus-grafana.ultimate-cicd-devops.local:9090

# Grafana
curl -I http://prometheus-grafana.ultimate-cicd-devops.local:3000
```


**All should return HTTP 200 OK or similar.**


### Verification

**Service discovery DNS:** All internal service names resolve correctly.


---


## Task 4: Configure Prometheus Targets

Set up Prometheus to monitor your infrastructure.


### Instructions

**4.1** Open Prometheus in browser:

```
http://<PROMETHEUS_GRAFANA_PUBLIC_IP>:9090
```


**4.2** Click "Status" → "Targets" (top menu).


**4.3** You should see targets configured by the cloud-init script:

```
Target                          State    Labels
prometheus (9090)               UP       job="prometheus"
node-exporter (9100)            UP       job="node"
```


**If targets are DOWN or missing:**


**SSH to Prometheus server:**

```bash
ssh -i k8s-pipeline-key.pem ubuntu@<PROMETHEUS_GRAFANA_PUBLIC_IP>
```


**Check Prometheus config:**

```bash
cat /etc/prometheus/prometheus.yml
```


**Verify it includes:**

```yaml
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
```


**If config is correct but targets are down, restart services:**

```bash
sudo systemctl restart prometheus
sudo systemctl restart node_exporter
```


**Exit SSH:**

```bash
exit
```


**4.4** Back in browser, refresh Prometheus targets page.


### Verification

**Prometheus targets:** All showing "UP" state.


---


## Task 5: Configure Grafana Dashboards

Set up Grafana for monitoring visualization.


### Instructions

**5.1** Open Grafana in browser:

```
http://<PROMETHEUS_GRAFANA_PUBLIC_IP>:3000
```


**5.2** Log in with default credentials:

```
Username: admin
Password: admin
```


**5.3** Grafana will ask you to change the password.

**Set new password:** (write it down!)


**5.4** Add Prometheus as data source:

* Click "⚙️" (Configuration) → "Data sources"
* Click "Add data source"
* Select "Prometheus"
* Enter URL: `http://localhost:9090`
* Scroll down and click "Save & Test"
* You should see: "Data source is working"


**5.5** Import a dashboard:

* Click "+" → "Import"
* In "Import via grafana.com", enter dashboard ID: `1860`
* Click "Load"
* Select "Prometheus" as data source
* Click "Import"


**5.6** You should now see "Node Exporter Full" dashboard with system metrics.


**Metrics displayed:**
* CPU usage
* Memory usage
* Disk I/O
* Network traffic
* System load


**5.7** Explore the dashboard:

* Change time range (top right)
* Refresh data
* Zoom in on specific metrics


### Verification

**Grafana:** Prometheus data source connected, Node Exporter dashboard showing live metrics.


---


## Task 6: End-to-End Pipeline Test

Trigger a new build by making a code change.


### Instructions

**6.1** On your local machine, clone the repository (if not already):

```bash
cd ~/Documents/PROJECTS/ec2-k8s
git pull origin main
```


**6.2** Make a simple change to trigger a build:

**Edit README.md:**

```bash
echo "\n\nLast tested: $(date)" >> README.md
```


**6.3** Commit and push:

```bash
git add README.md
git commit -m "Test CI/CD pipeline trigger"
git push origin main
```


**6.4** Wait for Jenkins to detect the change (up to 5 minutes based on poll schedule).


**Or trigger manually:**

* Go to Jenkins → boardgame-cicd project
* Click "Build Now"


**6.5** Watch the build execute (should be faster now, ~5-8 minutes).


**6.6** Verify all 11 stages pass.


**6.7** Check build artifacts:

* Nexus: New snapshot version uploaded
* SonarQube: New analysis created
* Docker Hub: Image updated with new digest
* Kubernetes: Pods restarted with new image


### Verification

**Complete pipeline executed successfully** with code change triggering automated build.


---


## Task 7: Application Functionality Testing

Thoroughly test the deployed application.


### Instructions

**7.1** Open application in browser:

```
http://<WORKER_NODE_IP>:<NODE_PORT>
```


**7.2** Test home page:

* Should load without errors
* Check for boardgame branding/title


**7.3** Test login functionality:

**Login with:**

```
Username: bugs
Password: bunny
```


**After login, you should see:** User dashboard or welcome message.


**7.4** Test logout:

* Click "Logout"
* Should return to login page


**7.5** Test with second user:

```
Username: daffy
Password: duck
```


**7.6** Test invalid credentials:

```
Username: invalid
Password: wrong
```


**Should see:** Error message or login failure.


**7.7** Test application features:

* Browse boardgames
* Search functionality
* Database queries


**7.8** Check browser console for errors:

* Right-click → Inspect → Console tab
* Should not have critical JavaScript errors


### Verification

**Application:** Fully functional with working authentication and database operations.


---


## Task 8: Security Verification

Review security scan results.


### Instructions

**8.1** Open Jenkins → boardgame-cicd → Latest build.


**8.2** Click "Console Output".


**8.3** Search for "Trivy Scan" section:

```
[Pipeline] stage (Trivy Scan)
```


**8.4** Review the scan results:

```
Total: X (CRITICAL: Y, HIGH: Z, MEDIUM: A, LOW: B)
```


**8.5** If there are CRITICAL or HIGH vulnerabilities:

**View details in console output:**

```
Package: <package-name>
Vulnerability: CVE-XXXX-XXXXX
Severity: CRITICAL
Fixed Version: X.X.X
```


**8.6** For production, you should:

* Update base image in Dockerfile
* Update dependencies in pom.xml
* Rebuild and rescan


**For learning purposes:** Note the vulnerabilities for future reference.


**8.7** Check SonarQube security findings:

* Open SonarQube → boardgame project
* Click "Security Hotspots" tab
* Review any security issues detected in code


### Verification

**Security scanning:** Trivy and SonarQube scans completed, results documented.


---


## Task 9: Performance Check

Verify application performance and resource usage.


### Instructions

**9.1** SSH to K8s master (if not already connected).


**9.2** Check pod resource usage:

```bash
kubectl top pods -n webapps
```


**Expected output:**

```
NAME                         CPU(cores)   MEMORY(bytes)
boardgame-xxxxxxxxxx-xxxxx   50m          512Mi
boardgame-xxxxxxxxxx-xxxxx   45m          498Mi
```


**9.3** Check pod resource limits:

```bash
kubectl describe deployment boardgame -n webapps | grep -A 5 Limits
```


**9.4** Perform load test (simple):

```bash
# Install Apache Bench if not available
sudo apt-get update
sudo apt-get install -y apache2-utils

# Get service NodePort
NODE_PORT=$(kubectl get svc boardgame -n webapps -o jsonpath='{.spec.ports[0].nodePort}')

# Run simple load test (100 requests, 10 concurrent)
ab -n 100 -c 10 http://localhost:$NODE_PORT/
```


**Expected output:**

```
Requests per second:    XX [#/sec]
Time per request:       XX [ms]
Failed requests:        0
```


**9.5** Monitor pod behavior during load:

```bash
kubectl get pods -n webapps -w
```


**Pods should remain Running and not restart.**


**9.6** Check application logs:

```bash
kubectl logs deployment/boardgame -n webapps --tail=50
```


**Should show HTTP requests being processed.**


### Verification

**Application performance:** Handles load appropriately, no crashes or errors.


---


## Task 10: Backup Critical Data

Save important information and configurations.


### Instructions

**10.1** On your local machine, create a backup directory:

```bash
mkdir -p ~/Documents/PROJECTS/ec2-k8s/backups
cd ~/Documents/PROJECTS/ec2-k8s/backups
```


**10.2** Save Terraform outputs:

```bash
cd ~/Documents/PROJECTS/ec2-k8s
terraform output > backups/terraform-outputs-$(date +%Y%m%d).txt
```


**10.3** Save Kubernetes config from master:

```bash
ssh -i k8s-pipeline-key.pem ubuntu@<JENKINS_MASTER_PUBLIC_IP> \
  'cat ~/.kube/config' > backups/kubeconfig-$(date +%Y%m%d).yaml
```


**10.4** Document instance IPs and credentials:

**Create file:** `backups/deployment-info-$(date +%Y%m%d).txt`

```
=== EC2 Instance IPs ===
Jenkins/K8s Master: <IP>
K8s Worker 1: <IP>
K8s Worker 2: <IP>
Nexus/SonarQube: <IP>
Prometheus/Grafana: <IP>

=== Service URLs ===
Jenkins: http://<IP>:8080
SonarQube: http://<IP>:9000
Nexus: http://<IP>:8081
Prometheus: http://<IP>:9090
Grafana: http://<IP>:3000
Boardgame App: http://<WORKER_IP>:<NODE_PORT>

=== Credentials ===
Jenkins: admin / <password>
SonarQube: admin / <password>
Nexus: admin / admin123
Grafana: admin / <password>
Docker Hub: temitayocharles / <password>
GitHub: temitayocharles / <token>

=== Docker Hub Image ===
Repository: temitayocharles/boardgame
Tag: latest
Last Updated: <date>

=== Kubernetes ===
Namespace: webapps
Deployment: boardgame
Replicas: 2
Service: LoadBalancer (NodePort)
```


**10.5** Save Jenkins job configuration:

* Go to Jenkins → boardgame-cicd
* Click "Configure"
* Copy all settings to a text file


**10.6** Export SonarQube quality profile (optional):

* SonarQube → Quality Profiles
* Click "Sonar way" → "Back up"
* Save the XML file


### Verification

**Backups created:** Outputs, configs, credentials documented and saved locally.


---


## Task 11: Complete Success Checklist

Final comprehensive verification.


### Instructions

**11.1** Go through this complete checklist:

```
INFRASTRUCTURE:
[ ] All 5 EC2 instances running
[ ] Security groups properly configured
[ ] Service discovery DNS working
[ ] SSH access to all instances works

KUBERNETES:
[ ] 3 nodes in Ready state
[ ] All kube-system pods Running
[ ] Calico network plugin installed
[ ] CoreDNS functioning
[ ] webapps namespace exists
[ ] Application pods running (2/2)

JENKINS:
[ ] Accessible at port 8080
[ ] Admin user configured
[ ] All required plugins installed
[ ] Tools configured (JDK, Maven, Docker, SonarQube Scanner)
[ ] All credentials configured (4 total)
[ ] SonarQube server configured
[ ] Maven settings file created
[ ] Pipeline job created (boardgame-cicd)
[ ] At least one successful build

SONARQUBE:
[ ] Accessible at port 9000
[ ] Admin password changed
[ ] Authentication token created
[ ] Integration with Jenkins working
[ ] Code analysis completed at least once
[ ] Quality gate evaluated

NEXUS:
[ ] Accessible at port 8081
[ ] Admin password set to admin123
[ ] maven-releases repository exists
[ ] maven-snapshots repository exists
[ ] Snapshot redeployment enabled
[ ] Artifacts successfully published

DOCKER HUB:
[ ] Repository created (temitayocharles/boardgame)
[ ] At least one image pushed
[ ] Image tagged as 'latest'

APPLICATION:
[ ] Deployed to Kubernetes
[ ] 2 replicas running
[ ] Service created with NodePort
[ ] Accessible via browser
[ ] Login functionality works
[ ] Database operations functional

MONITORING:
[ ] Prometheus accessible at port 9090
[ ] Targets showing UP status
[ ] Metrics being collected
[ ] Grafana accessible at port 3000
[ ] Data source configured
[ ] Dashboard imported and showing data

CI/CD PIPELINE:
[ ] All 11 stages passing
[ ] Build triggered automatically on code change
[ ] Artifacts stored in Nexus
[ ] Code analyzed by SonarQube
[ ] Docker image built and scanned
[ ] Image pushed to Docker Hub
[ ] Application deployed to K8s
[ ] Deployment verified automatically

SECURITY:
[ ] Trivy scan completed
[ ] Vulnerabilities documented
[ ] SonarQube security hotspots reviewed
[ ] Authentication working on all services

BACKUPS:
[ ] Terraform outputs saved
[ ] Kubeconfig backed up
[ ] Credentials documented
[ ] Service URLs recorded
```


### Verification

**All checklist items:** Completed successfully.


---


## Task 12: Cost Optimization - Teardown

Clean up resources to avoid unnecessary AWS charges.


**IMPORTANT:** Only do this when you're done learning. You'll lose all data and configurations!


### Instructions

**12.1** Before destroying, take screenshots:

* Jenkins successful build
* SonarQube analysis results
* Nexus artifacts
* Docker Hub repository
* Grafana dashboards
* Application running in browser


**12.2** On your local machine:

```bash
cd ~/Documents/PROJECTS/ec2-k8s
```


**12.3** Review what will be destroyed:

```bash
terraform plan -destroy
```


**12.4** Destroy all infrastructure:

```bash
terraform destroy
```


**You will be prompted:**

```
Do you really want to destroy all resources?
  Enter a value: yes
```


**Type:** `yes`


**12.5** Wait for destruction to complete (~5 minutes).


**Expected output:**

```
Destroy complete! Resources: 35 destroyed.
```


**12.6** Verify in AWS Console:

* EC2 → Instances: All terminated
* VPC → Security Groups: Custom ones deleted (default VPC SG remains)
* CloudWatch → Service Discovery: Namespace deleted


**12.7** Verify Docker Hub repository still exists:

* Your images remain in Docker Hub even after infrastructure is destroyed


**12.8** Your code repository is safe:

* GitHub repository remains untouched
* All code and configurations preserved


### Verification

**All AWS resources destroyed.** Code and Docker images preserved for future use.


---


## Rebuilding Later

**To rebuild the entire infrastructure:**

```bash
cd ~/Documents/PROJECTS/ec2-k8s

# Deploy infrastructure
terraform apply

# Wait for cloud-init to complete (5-7 minutes)

# Follow guides again from Step 5 (Kubernetes setup)
# Jenkins, SonarQube, Nexus will need reconfiguration
# Or use saved backups to speed up reconfiguration
```


---


## Final Summary

**What You Accomplished:**

You have successfully built and deployed a **production-grade CI/CD pipeline** from scratch!


**Infrastructure:**
* 5 EC2 instances managed by Terraform
* Service discovery with AWS Cloud Map
* OIDC authentication for GitHub Actions
* Complete networking and security groups


**Kubernetes Cluster:**
* 1 master node + 2 worker nodes
* Calico network plugin
* Application deployment with 2 replicas
* Service exposure via NodePort


**CI/CD Pipeline:**
* Jenkins with 11-stage pipeline
* Automated code compilation and testing
* SonarQube code quality analysis
* Nexus artifact repository
* Docker image building and security scanning
* Kubernetes automated deployment


**Monitoring:**
* Prometheus metrics collection
* Grafana visualization
* Infrastructure and application monitoring


**Skills Learned:**
* Infrastructure as Code with Terraform
* Kubernetes cluster administration
* Jenkins pipeline creation and configuration
* Docker containerization
* Security scanning with Trivy
* Code quality analysis with SonarQube
* Artifact management with Nexus
* Service discovery configuration
* System monitoring setup


---


## Documentation Created

**Guides you completed:**

1. 00-START-HERE.md - Navigation and overview
2. 01-architecture.md - System design
3. 02-aws-setup.md - AWS prerequisites
4. 03-local-setup.md - Terraform configuration
5. 04-terraform-deploy.md - Infrastructure deployment
6. 05-kubernetes-setup.md - K8s cluster initialization
7. 06-jenkins-setup.md - Jenkins configuration
8. 07-sonarqube-setup.md - SonarQube setup
9. 08-nexus-setup.md - Nexus configuration
10. 09-pipeline-setup.md - Pipeline creation and execution
11. 10-verification.md - Comprehensive testing (this guide)


---


## Next Steps for Learning

**To expand your knowledge:**

1. **Add more pipeline stages:**
   * Integration tests
   * Performance tests
   * Security compliance checks

2. **Enhance Kubernetes deployment:**
   * Ingress controller
   * TLS/SSL certificates
   * Horizontal Pod Autoscaling

3. **Implement advanced monitoring:**
   * Application-specific metrics
   * Custom Grafana dashboards
   * Alerting rules in Prometheus

4. **Security improvements:**
   * HashiCorp Vault for secrets
   * Network policies
   * Pod security policies

5. **Multi-environment setup:**
   * Dev, staging, production environments
   * Environment-specific configurations
   * Blue-green deployments


---


**Congratulations on completing this comprehensive CI/CD pipeline project!**


You now have real-world DevOps experience with industry-standard tools and practices.
