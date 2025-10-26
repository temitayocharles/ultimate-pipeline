# Step 9: Create and Run CI/CD Pipeline

**Duration:** 25-30 minutes

**Goal:** Create Jenkins pipeline job and execute complete CI/CD workflow


---


## What You Will Do

* Create a new Pipeline job in Jenkins
* Configure GitHub repository connection
* Set up Jenkinsfile from repository
* Run the first build
* Watch all 11 stages execute
* Verify successful deployment


---


## Task 1: Create New Pipeline Job

Set up a new Jenkins pipeline project.


### Instructions

**1.1** Open Jenkins in your browser:

```
http://<JENKINS_MASTER_PUBLIC_IP>:8080
```


**1.2** Log in with your admin credentials.


**1.3** From the Dashboard, click "New Item" (left sidebar).


**1.4** Fill in the form:

```
Enter an item name: boardgame-cicd
```


**1.5** Select "Pipeline" (scroll down to find it).


**1.6** Click "OK" at the bottom.


### Verification

**You should see:** Pipeline configuration page with multiple tabs (General, Build Triggers, Pipeline, etc.).


---


## Task 2: Configure Pipeline Description

Add a description for the pipeline.


### Instructions

**2.1** In the "General" section, check "Description" box if not already visible.


**2.2** Enter description:

```
Complete CI/CD pipeline for Boardgame Database application.
Includes: build, test, code analysis, security scan, artifact storage, Docker build, and Kubernetes deployment.
```


**2.3** Do NOT click Save yet (we have more to configure).


### Verification

**You see:** Description field filled in.


---


## Task 3: Configure GitHub Project (Optional)

Link the pipeline to your GitHub repository.


### Instructions

**3.1** In "General" section, check "GitHub project" checkbox.


**3.2** Enter Project URL:

```
https://github.com/temitayocharles/ultimate-pipeline/
```


**Make sure the URL ends with a slash (/).**


**3.3** Do NOT click Save yet.


### Verification

**You see:** GitHub project URL configured.


---


## Task 4: Configure Build Triggers

Set up automatic builds on code changes.


### Instructions

**4.1** Scroll to "Build Triggers" section.


**4.2** Check "Poll SCM" checkbox.


**What this does:** Jenkins will check GitHub for changes every few minutes.


**4.3** In the "Schedule" field, enter:

```
H/5 * * * *
```


**What this means:** Check for changes every 5 minutes.


**Syntax explanation:**
* H/5: Every 5 minutes (H = hash to distribute load)
* *: Every hour
* *: Every day
* *: Every month
* *: Every day of week


**For manual builds only (alternative):**

If you prefer to trigger builds manually only, leave all checkboxes unchecked.


**4.4** Do NOT click Save yet.


### Verification

**You see:** "Poll SCM" configured with schedule `H/5 * * * *`.


---


## Task 5: Configure Pipeline from SCM

Tell Jenkins to use Jenkinsfile from your GitHub repository.


### Instructions

**5.1** Scroll to "Pipeline" section.


**5.2** In "Definition" dropdown, select:

```
Pipeline script from SCM
```


**5.3** In "SCM" dropdown, select:

```
Git
```


**New fields will appear.**


**5.4** In "Repository URL", enter:

```
https://github.com/temitayocharles/ultimate-pipeline.git
```


**5.5** In "Credentials" dropdown:

**If your repository is public:**
Select: `- none -`


**If your repository is private:**
Select: `git-cred` (the GitHub credentials you created in Step 6)


**5.6** In "Branch Specifier" field, verify it shows:

```
*/main
```


**If your repository uses `master` branch instead of `main`, change it to:**

```
*/master
```


**5.7** In "Script Path" field, enter:

```
ci-cd/Jenkinsfile
```


**This tells Jenkins where to find the Jenkinsfile in your repository.**


**5.8** Leave all other settings as default.


**5.9** Now click "Save" button (bottom of page).


### Verification

**You should see:** Pipeline project page with "Build Now" button in left sidebar.


---


## Task 6: Trigger First Build

Run the pipeline for the first time.


### Instructions

**6.1** From the pipeline project page, click "Build Now" (left sidebar).


**6.2** You should see a build appear in "Build History" (left sidebar):

```
#1 <timestamp>
```


**6.3** Click on "#1" to open the build.


**6.4** Click "Console Output" (left sidebar).


**You will see:** Real-time build logs.


**The pipeline will execute these 11 stages:**

1. **Git Checkout** - Clone repository
2. **Compile** - Run `mvn compile`
3. **Unit Tests** - Run `mvn test`
4. **SonarQube Analysis** - Analyze code quality
5. **Quality Gate** - Wait for SonarQube results
6. **Build** - Run `mvn package` to create JAR
7. **Publish to Nexus** - Deploy artifact to Nexus
8. **Build Docker Image** - Create Docker image
9. **Trivy Scan** - Security scan of Docker image
10. **Push to Docker Hub** - Upload image to Docker Hub
11. **Deploy to Kubernetes** - Deploy to K8s cluster


**Expected duration:** 8-12 minutes for first build (longer because tools need to download dependencies).


### Verification

**You should see:** Console output showing each stage executing.


---


## Task 7: Monitor Build Progress

Watch the pipeline stages execute.


### Instructions

**7.1** Go back to the build page (click "#1" in breadcrumb at top).


**7.2** You should see "Stage View" showing all stages.


**Each stage will show:**
* Blue/Green = Success
* Red = Failed
* Gray/Flashing = In progress


**7.3** Watch the stages progress:


**Stage 1: Git Checkout**
```
Expected output:
Cloning repository...
Checking out Revision abc123...
```
Duration: ~30 seconds


**Stage 2: Compile**
```
Expected output:
[INFO] Building Board Game Database Project
[INFO] Compiling 10 source files...
[INFO] BUILD SUCCESS
```
Duration: ~2 minutes (first time downloads Maven dependencies)


**Stage 3: Unit Tests**
```
Expected output:
Running com.boardgame.BoardGameDatabaseApplicationTests
Tests run: X, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```
Duration: ~1 minute


**Stage 4: SonarQube Analysis**
```
Expected output:
[INFO] SonarQube Scanner 6.2.1.4610
[INFO] Analyzing on SonarQube server...
[INFO] ANALYSIS SUCCESSFUL
```
Duration: ~2 minutes


**Stage 5: Quality Gate**
```
Expected output:
Checking Quality Gate status...
Quality Gate passed
```
Duration: ~30 seconds


**Stage 6: Build**
```
Expected output:
[INFO] Building jar: .../target/database-0.0.1-SNAPSHOT.jar
[INFO] BUILD SUCCESS
```
Duration: ~1 minute


**Stage 7: Publish to Nexus**
```
Expected output:
Uploading to maven-snapshots...
Uploaded to maven-snapshots: .../database-0.0.1-SNAPSHOT.jar
```
Duration: ~30 seconds


**Stage 8: Build Docker Image**
```
Expected output:
Successfully built abc123def456
Successfully tagged temitayocharles/boardgame:latest
```
Duration: ~2 minutes


**Stage 9: Trivy Scan**
```
Expected output:
Scanning Docker image...
Total: 0 (CRITICAL: 0, HIGH: 0, MEDIUM: 0, LOW: 0)
```
Duration: ~2 minutes


**Stage 10: Push to Docker Hub**
```
Expected output:
The push refers to repository [docker.io/temitayocharles/boardgame]
latest: digest: sha256:abc123... size: 2841
```
Duration: ~1 minute


**Stage 11: Deploy to Kubernetes**
```
Expected output:
deployment.apps/boardgame configured
service/boardgame configured
Waiting for deployment to be ready...
deployment "boardgame" successfully rolled out
```
Duration: ~30 seconds


### Verification

**All 11 stages should show green/blue (success).**


---


## Task 8: Review Build Results

Check that the build completed successfully.


### Instructions

**8.1** When all stages complete, go to "Console Output".


**8.2** Scroll to the bottom.


**8.3** You should see:

```
[Pipeline] End of Pipeline
Finished: SUCCESS
```


**8.4** Go back to the pipeline project page.


**8.5** You should see:

```
Last Successful Build: #1
Last Stable Build: #1
```


### Verification

**Build status:** SUCCESS (green checkmark or blue ball).


---


## Task 9: Verify Artifacts in Nexus

Check that artifacts were published to Nexus.


### Instructions

**9.1** Open Nexus in browser:

```
http://<NEXUS_SONARQUBE_PUBLIC_IP>:8081
```


**9.2** Log in (admin/admin123).


**9.3** Click "Browse" (left sidebar).


**9.4** Click "maven-snapshots".


**9.5** Navigate through folders:

```
com/
  → boardgame/
    → database/
      → 0.0.1-SNAPSHOT/
```


**9.6** You should see:

```
database-0.0.1-SNAPSHOT.jar
database-0.0.1-SNAPSHOT.pom
```


**These are your Maven artifacts!**


### Verification

**Artifacts exist in Nexus** maven-snapshots repository.


---


## Task 10: Verify Code Analysis in SonarQube

Check code quality analysis results.


### Instructions

**10.1** Open SonarQube in browser:

```
http://<NEXUS_SONARQUBE_PUBLIC_IP>:9000
```


**10.2** Log in (admin / your SonarQube password).


**10.3** You should see a project:

```
com.boardgame:database
```


**10.4** Click on the project.


**10.5** Review the analysis:

```
Quality Gate: Passed (or Failed if quality issues exist)
Bugs: X
Vulnerabilities: X
Code Smells: X
Coverage: X%
Duplications: X%
```


**10.6** Click on each metric to see details.


### Verification

**SonarQube analyzed the code** and shows quality metrics.


---


## Task 11: Verify Docker Image in Docker Hub

Check that the image was pushed to Docker Hub.


### Instructions

**11.1** Open Docker Hub in browser:

```
https://hub.docker.com
```


**11.2** Log in with your Docker Hub credentials.


**11.3** Click on "Repositories".


**11.4** You should see:

```
temitayocharles/boardgame
```


**11.5** Click on it.


**11.6** You should see:

```
Tag: latest
Last Pushed: <recent timestamp>
```


**11.7** Note the image size and digest.


### Verification

**Docker image exists** in your Docker Hub repository with tag `latest`.


---


## Task 12: Verify Deployment in Kubernetes

Check that the application is running in Kubernetes.


### Instructions

**12.1** SSH to Kubernetes master:

```bash
ssh -i k8s-pipeline-key.pem ubuntu@<JENKINS_MASTER_PUBLIC_IP>
```


**12.2** Check deployment:

```bash
kubectl get deployments -n webapps
```


**Expected output:**

```
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
boardgame   2/2     2            2           Xm
```


**READY should be 2/2** (2 replicas running).


**12.3** Check pods:

```bash
kubectl get pods -n webapps
```


**Expected output:**

```
NAME                         READY   STATUS    RESTARTS   AGE
boardgame-xxxxxxxxxx-xxxxx   1/1     Running   0          Xm
boardgame-xxxxxxxxxx-xxxxx   1/1     Running   0          Xm
```


**Both pods should be Running.**


**12.4** Check service:

```bash
kubectl get svc -n webapps
```


**Expected output:**

```
NAME        TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
boardgame   LoadBalancer   10.96.xxx.xxx   <pending>     80:xxxxx/TCP   Xm
```


**Note:** EXTERNAL-IP will show `<pending>` because we're not using a cloud load balancer. The NodePort (xxxxx) is what we'll use.


**12.5** Get the NodePort:

```bash
kubectl get svc boardgame -n webapps -o jsonpath='{.spec.ports[0].nodePort}'
```


**Example output:** `32000`


**12.6** Test application from master node:

```bash
curl http://localhost:<NODE_PORT>
```


Replace `<NODE_PORT>` with the number from previous step.


**Expected output:** HTML content of the boardgame application.


**12.7** Exit SSH:

```bash
exit
```


### Verification

**Application is deployed and running** in Kubernetes with 2 healthy pods.


---


## Task 13: Access Application in Browser

Open the boardgame application.


### Instructions

**13.1** Get one of the worker node public IPs from your terraform outputs.


**13.2** Open in browser:

```
http://<WORKER_NODE_PUBLIC_IP>:<NODE_PORT>
```


Example: `http://54.123.45.67:32000`


**13.3** You should see the Boardgame Database application home page.


**13.4** Test login functionality:

**Click "Login" or navigate to login page.**


**Try these credentials:**

```
Username: bugs
Password: bunny
```

Or:

```
Username: daffy
Password: duck
```


**13.5** Explore the application.


### Verification

**Application is accessible** via browser and login works.


---


## Checklist: Pipeline Setup Complete

Verify all tasks:

```
[ ] Pipeline job created (name: boardgame-cicd)
[ ] GitHub repository configured
[ ] Jenkinsfile path set to ci-cd/Jenkinsfile
[ ] First build triggered and completed successfully
[ ] All 11 stages passed (green/blue)
[ ] Build status: SUCCESS
[ ] Artifacts published to Nexus (maven-snapshots)
[ ] Code analyzed in SonarQube
[ ] Docker image pushed to Docker Hub
[ ] Application deployed to Kubernetes (2/2 pods running)
[ ] Application accessible via browser
[ ] Login functionality works
```


---


## Important Information to Record

**Add to your notes:**

```
=== Pipeline Details ===
Job Name: boardgame-cicd
Repository: https://github.com/temitayocharles/ultimate-pipeline.git
Branch: main
Jenkinsfile Path: ci-cd/Jenkinsfile
Poll SCM: H/5 * * * * (every 5 minutes)

=== Build #1 Results ===
Status: SUCCESS
Duration: ~8-12 minutes
Stages: 11/11 passed
Maven Artifact: database-0.0.1-SNAPSHOT.jar
Docker Image: temitayocharles/boardgame:latest
K8s Namespace: webapps
K8s Deployment: boardgame (2 replicas)

=== Application Access ===
URL: http://<WORKER_IP>:<NODE_PORT>
Login: bugs/bunny or daffy/duck
```


---


## Troubleshooting

**Problem:** Build fails at "Git Checkout" stage

**Solution:**
1. Verify GitHub repository URL is correct
2. If repository is private, ensure git-cred credentials are configured
3. Check network connectivity from Jenkins to GitHub


**Problem:** Build fails at "Compile" or "Test" stage

**Solution:**
```
Check console output for Maven errors:
- Missing dependencies (wait for Maven to download)
- Java version mismatch (verify JDK 17 configured)
- Code compilation errors (fix in source code)
```


**Problem:** Build fails at "SonarQube Analysis" stage

**Solution:**
1. Verify SonarQube is running: `docker ps | grep sonar`
2. Check SonarQube server configured in Jenkins (Step 6, Task 14)
3. Verify sonar-token credential is correct
4. Test connection: `curl http://nexus-sonarqube.ultimate-cicd-devops.local:9000`


**Problem:** Quality Gate fails

**Solution:**
1. Go to SonarQube and review failed conditions
2. Fix code quality issues, or
3. Create a more relaxed quality gate (see Step 7, Task 4)
4. Or temporarily disable quality gate in Jenkinsfile


**Problem:** Build fails at "Publish to Nexus" stage

**Solution:**
```
Common causes:
- Nexus credentials incorrect in Maven settings
- Nexus not running: docker ps | grep nexus
- Repository doesn't exist in Nexus
- Check console for 401 Unauthorized error

Verify:
1. Nexus admin password is admin123
2. Jenkins global-settings has correct credentials
3. Repository IDs in pom.xml match Nexus (maven-releases, maven-snapshots)
```


**Problem:** Build fails at "Push to Docker Hub" stage

**Solution:**
1. Verify docker-cred credentials in Jenkins
2. Log in to Docker Hub and check quota limits
3. Ensure repository name matches: temitayocharles/boardgame
4. Check console for authentication errors


**Problem:** Build fails at "Deploy to Kubernetes" stage

**Solution:**
```bash
# SSH to Jenkins master
ssh ubuntu@<JENKINS_IP>

# Test kubectl access
kubectl get nodes

# Check namespace exists
kubectl get namespace webapps

# Verify k8-cred credential contains valid kubeconfig
```


**Problem:** Application pods not running

**Solution:**
```bash
# Check pod status
kubectl get pods -n webapps

# Check pod logs
kubectl logs <pod-name> -n webapps

# Describe pod to see events
kubectl describe pod <pod-name> -n webapps

# Common issues:
# - Image pull error (check Docker Hub image exists)
# - Insufficient resources (check node resources)
# - Application crash (check logs)
```


**Problem:** Cannot access application in browser

**Solution:**
1. Verify security group allows NodePort range (30000-32767)
2. Check pods are Running: `kubectl get pods -n webapps`
3. Test from within cluster first: `curl http://localhost:<NODE_PORT>`
4. Try accessing from different worker node IP


**Problem:** Pipeline takes very long (>20 minutes)

**Solution:**
1. First build is slower (Maven downloads dependencies)
2. Subsequent builds should be 5-8 minutes
3. Check if SonarQube analysis is hanging (timeout issue)
4. Verify network speed between Jenkins and Nexus/SonarQube


---


## Next Steps

Proceed to **Step 10: Verification and Testing** (`10-verification.md`)

You will perform comprehensive testing and create final documentation.


---


**Completion Time:** First build: 25-30 minutes. Subsequent builds: 5-8 minutes.


**Congratulations! Your complete CI/CD pipeline is working!**


You have successfully:
* Built a Java application with Maven
* Analyzed code quality with SonarQube
* Stored artifacts in Nexus
* Created and scanned a Docker image
* Deployed to Kubernetes automatically


This is a production-grade CI/CD pipeline!
