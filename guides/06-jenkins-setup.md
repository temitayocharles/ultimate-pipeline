# Step 6: Jenkins Configuration

**Duration:** 30-40 minutes (most detailed step)

**Goal:** Configure Jenkins with plugins, tools, and credentials for CI/CD pipeline


**Note:** This is the longest step because Jenkins has many settings. Take your time and follow carefully.


---


## What You Will Configure

* Jenkins initial setup and admin user
* 8 required plugins
* Java 17 (JDK)
* Maven 3.9.6
* Docker tool
* SonarQube scanner
* Credentials for Docker Hub, SonarQube, Kubernetes, and GitHub


---


## Task 1: Access Jenkins and Get Initial Password

Log in to Jenkins for the first time.


### Instructions

**1.1** Open Jenkins URL in your browser:

```
http://<JENKINS_MASTER_PUBLIC_IP>:8080
```


Replace `<JENKINS_MASTER_PUBLIC_IP>` with the IP from your terraform outputs.


**You will see:** "Unlock Jenkins" page asking for administrator password.


**1.2** Get the initial admin password from the server:


**Open a terminal and SSH to Jenkins master:**

```bash
cd ~/Documents/PROJECTS/ec2-k8s
ssh -i k8s-pipeline-key.pem ubuntu@<JENKINS_MASTER_PUBLIC_IP>
```


**Run this command:**

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```


**Expected output:** A long password like:
```
a771e06575b54f91bc56a42ccdbb2f76
```


**1.3** Copy this password.


**1.4** Paste it into the "Administrator password" field in your browser.


**1.5** Click "Continue".


### Verification

**You should now see:** "Customize Jenkins" page with plugin installation options.


---


## Task 2: Install Suggested Plugins

Install the basic Jenkins plugins.


### Instructions

**2.1** Click "Install suggested plugins".


**You will see:** A progress screen showing plugins being installed.


**Plugins being installed include:**
* Git
* GitHub
* Pipeline
* Credentials
* And many others...


**This process takes 3-5 minutes.**


**Wait for all plugins to complete.** Green checkmarks will appear next to each plugin.


### Verification

**When complete, you will see:** "Create First Admin User" page.


---


## Task 3: Create Admin User

Create your Jenkins administrator account.


### Instructions

**3.1** Fill in the form:

```
Username: admin
Password: <choose a strong password>
Confirm password: <same password>
Full name: <your name>
E-mail address: <your email>
```


**IMPORTANT:** Write down your username and password! You will need these to log in later.


**3.2** Click "Save and Continue".


**3.3** On "Instance Configuration" page, keep the default Jenkins URL:

```
http://<YOUR_IP>:8080/
```


**3.4** Click "Save and Finish".


**3.5** Click "Start using Jenkins".


### Verification

**You should now see:** Jenkins Dashboard with "Welcome to Jenkins!" message.


---


## Task 4: Install Additional Required Plugins

Install 8 more plugins needed for the CI/CD pipeline.


### Instructions

**4.1** From Jenkins Dashboard, click "Manage Jenkins" (left sidebar).


**4.2** Click "Plugins" (or "Manage Plugins").


**4.3** Click the "Available plugins" tab.


**Now install each plugin one by one:**


**Plugin 1: Eclipse Temurin Installer**

**4.4** In the search box, type: `Eclipse Temurin Installer`


**4.5** Check the box next to "Eclipse Temurin Installer".


**4.6** Click "Install" button (bottom of page).


**Wait for installation to complete** (shows "Success" in green).


**4.7** Click "Go back to top page".


**Repeat steps 4.1-4.7 for each of the following plugins:**


**Plugin 2: SonarQube Scanner**

Search for: `SonarQube Scanner`


**Plugin 3: Config File Provider**

Search for: `Config File Provider`


**Plugin 4: Pipeline Maven Integration**

Search for: `Pipeline Maven Integration`


**Plugin 5: Docker**

Search for: `Docker`


**Plugin 6: Docker Pipeline**

Search for: `Docker Pipeline`


**Plugin 7: Kubernetes CLI**

Search for: `Kubernetes CLI`


**Plugin 8: Kubernetes**

Search for: `Kubernetes`


**IMPORTANT:** After installing all plugins, you may see "Restart Jenkins when installation is complete and no jobs are running" checkbox. Check it.


**4.8** Wait for Jenkins to restart (takes 30-60 seconds).


**4.9** Log in again with your admin credentials.


### Verification

**Verify plugins are installed:**

1. Click "Manage Jenkins" → "Plugins"
2. Click "Installed plugins" tab
3. Search for each plugin name
4. All 8 should appear in the list with green checkmarks


---


## Task 5: Configure Java (JDK 17)

Tell Jenkins where to find Java 17.


### Instructions

**5.1** Click "Manage Jenkins" (left sidebar).


**5.2** Scroll down and click "Tools" (under "System Configuration" section).


**5.3** Scroll down to find "JDK installations" section.


**5.4** Click "Add JDK" button.


**5.5** Fill in the form:

```
Name: jdk17
```


**5.6** Uncheck "Install automatically" checkbox.


**5.7** In "JAVA_HOME" field, enter:

```
/usr/lib/jvm/java-17-openjdk-amd64
```


**This is the path where Java 17 is installed on the Jenkins server.**


**5.8** Do NOT click Save yet (we have more tools to configure).


### Verification

**You should see:** JDK configuration section filled with name "jdk17" and JAVA_HOME path.


---


## Task 6: Configure Maven

Configure Maven build tool.


### Instructions

**Still on the same "Tools" configuration page...**


**6.1** Scroll down to "Maven installations" section.


**6.2** Click "Add Maven" button.


**6.3** Fill in the form:

```
Name: maven3.6
```


**Note:** The name must be exactly `maven3.6` (our Jenkinsfile references this name).


**6.4** Check "Install automatically" checkbox.


**6.5** In the "Version" dropdown, select:

```
3.9.6
```


**Or the latest 3.x version available.**


**6.6** Do NOT click Save yet.


### Verification

**You should see:** Maven configuration with name "maven3.6" and version "3.9.6".


---


## Task 7: Configure Docker

Configure Docker tool for building images.


### Instructions

**Still on the same "Tools" page...**


**7.1** Scroll down to "Docker installations" section.


**7.2** Click "Add Docker" button.


**7.3** Fill in the form:

```
Name: docker
```


**7.4** Check "Install automatically" checkbox.


**7.5** In "Download from docker.com" dropdown, select:

```
Latest
```


**Or select a specific version like `24.0.7`.**


**7.6** Do NOT click Save yet.


### Verification

**You should see:** Docker configuration with name "docker".


---


## Task 8: Configure SonarQube Scanner

Configure SonarQube code analysis tool.


### Instructions

**Still on the same "Tools" page...**


**8.1** Scroll down to "SonarQube Scanner installations" section.


**8.2** Click "Add SonarQube Scanner" button.


**8.3** Fill in the form:

```
Name: sonar-scanner
```


**8.4** Check "Install automatically" checkbox.


**8.5** In "Version" dropdown, select:

```
SonarQube Scanner 6.2.1.4610
```


**Or the latest version available.**


**8.6** Now click "Save" button (at the bottom of the page).


### Verification

**You should see:** Jenkins Dashboard again. All tools are now configured.


---


## Task 9: Add Docker Hub Credentials

Add your Docker Hub username and password to Jenkins.


### Instructions

**9.1** From Dashboard, click "Manage Jenkins".


**9.2** Click "Credentials".


**9.3** Click "(global)" under "Stores scoped to Jenkins".


**9.4** Click "Add Credentials" (left sidebar).


**9.5** Fill in the form:

```
Kind: Username with password
Scope: Global
Username: <your Docker Hub username>
Password: <your Docker Hub password>
ID: docker-cred
Description: Docker Hub Credentials
```


**IMPORTANT:** The ID must be exactly `docker-cred` (our Jenkinsfile uses this).


**9.6** Click "Create".


### Verification

**You should see:** "docker-cred" in the credentials list with description "Docker Hub Credentials".


---


## Task 10: Add GitHub Credentials

Add GitHub personal access token for repository access.


### Instructions

**10.1** From credentials page, click "Add Credentials" again.


**10.2** Fill in the form:

```
Kind: Username with password
Scope: Global
Username: <your GitHub username>
Password: <your GitHub personal access token>
ID: git-cred
Description: GitHub Credentials
```


**If you don't have a GitHub token:**

1. Go to GitHub.com → Settings → Developer settings → Personal access tokens
2. Click "Generate new token (classic)"
3. Give it a name like "Jenkins"
4. Select scope: `repo` (full control of private repositories)
5. Click "Generate token"
6. Copy the token immediately (you won't see it again)
7. Use this as the password in Jenkins


**10.3** Click "Create".


### Verification

**You should see:** Both "docker-cred" and "git-cred" in the credentials list.


---


## Task 11: Configure Kubernetes Credentials

Add Kubernetes config file so Jenkins can deploy to the cluster.


### Instructions

**11.1** First, get the Kubernetes config file from the master node:


**In your terminal (SSH to Jenkins master if not already connected):**

```bash
cat ~/.kube/config
```


**11.2** Copy the ENTIRE output (from `apiVersion` to the end).


**11.3** Back in Jenkins browser, click "Add Credentials".


**11.4** Fill in the form:

```
Kind: Secret file
Scope: Global
File: <click Choose File, then create a file with the config content>
ID: k8-cred
Description: Kubernetes Config
```


**Alternative method (easier):**

```
Kind: Secret text
Scope: Global
Secret: <paste the entire kubectl config content here>
ID: k8-cred
Description: Kubernetes Config
```


**11.5** Click "Create".


### Verification

**You should see:** "k8-cred" in the credentials list.


---


## Task 12: Get SonarQube Token

Generate authentication token from SonarQube.


### Instructions

**12.1** Open SonarQube in a new browser tab:

```
http://<SONARQUBE_IP>:9000
```


**12.2** Log in with default credentials:

```
Username: admin
Password: admin
```


**12.3** SonarQube will prompt you to change the password.

**Set new password:** (write it down!)


**12.4** After login, click on "A" icon (top right) → "My Account".


**12.5** Click "Security" tab.


**12.6** In "Generate Tokens" section:

```
Name: jenkins-token
Type: Global Analysis Token
Expires in: No expiration
```


**12.7** Click "Generate".


**12.8** Copy the token immediately.

**It looks like:** `squ_1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q8r9s0`


**You cannot see this token again after closing this page!**


### Verification

**You should have:** A SonarQube token copied and saved in your notes.


---


## Task 13: Add SonarQube Token to Jenkins

Store the SonarQube token in Jenkins.


### Instructions

**13.1** Back in Jenkins, go to "Manage Jenkins" → "Credentials".


**13.2** Click "Add Credentials".


**13.3** Fill in the form:

```
Kind: Secret text
Scope: Global
Secret: <paste your SonarQube token>
ID: sonar-token
Description: SonarQube Authentication Token
```


**13.4** Click "Create".


### Verification

**You should now have 4 credentials:**
* docker-cred
* git-cred
* k8-cred
* sonar-token


---


## Task 14: Configure SonarQube Server in Jenkins

Connect Jenkins to SonarQube server.


### Instructions

**14.1** Click "Manage Jenkins" → "System" (under "System Configuration").


**14.2** Scroll down to "SonarQube servers" section.


**14.3** Check "Enable injection of SonarQube server configuration" checkbox.


**14.4** Click "Add SonarQube" button.


**14.5** Fill in the form:

```
Name: sonar
Server URL: http://nexus-sonarqube.ultimate-cicd-devops.local:9000
Server authentication token: <select "sonar-token" from dropdown>
```


**Note:** We use the service discovery DNS name instead of IP address.


**14.6** Click "Save" (at bottom of page).


### Verification

**You should see:** Dashboard again. SonarQube is now connected.


---


## Task 15: Configure Maven Settings for Nexus

Create Maven settings file for artifact deployment.


### Instructions

**15.1** Click "Manage Jenkins" → "Managed files" (under "System Configuration").


**If you don't see "Managed files":**
* The Config File Provider plugin might need activation
* Go to "Manage Jenkins" → "Configure System" and look for "Managed files" section


**15.2** Click "Add a new Config" button.


**15.3** Select "Global Maven settings.xml".


**15.4** Click "Next" or "Submit".


**15.5** Fill in the form:

```
ID: global-settings
Name: Global Maven Settings
Comment: Maven settings for Nexus deployment
```


**15.6** In the "Content" section, replace everything with:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                              http://maven.apache.org/xsd/settings-1.0.0.xsd">
  
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


**Note:** We'll set up Nexus password in Step 8. The default admin password will be changed to "admin123".


**15.7** Click "Save" or "Submit".


### Verification

**You should see:** "global-settings" in the list of managed files.


---


## Checklist: Jenkins Configuration Complete

Verify all configurations before proceeding:

```
[ ] Jenkins accessible at http://<IP>:8080
[ ] Admin user created and password saved
[ ] All 8 required plugins installed
[ ] JDK 17 configured (name: jdk17)
[ ] Maven configured (name: maven3.6)
[ ] Docker configured (name: docker)
[ ] SonarQube Scanner configured (name: sonar-scanner)
[ ] Docker Hub credentials added (ID: docker-cred)
[ ] GitHub credentials added (ID: git-cred)
[ ] Kubernetes credentials added (ID: k8-cred)
[ ] SonarQube token added (ID: sonar-token)
[ ] SonarQube server configured (name: sonar)
[ ] Maven global settings file created (ID: global-settings)
```


---


## Important Information to Record

**Add to your notes:**

```
=== Jenkins Access ===
URL: http://<IP>:8080
Username: admin
Password: <your password>

=== Tool Names (used in Jenkinsfile) ===
JDK: jdk17
Maven: maven3.6
Docker: docker
SonarQube Scanner: sonar-scanner

=== Credential IDs (used in Jenkinsfile) ===
Docker Hub: docker-cred
GitHub: git-cred
Kubernetes: k8-cred
SonarQube: sonar-token

=== SonarQube Server ===
Name in Jenkins: sonar
URL: http://nexus-sonarqube.ultimate-cicd-devops.local:9000
Token: <saved in sonar-token credential>

=== Maven Settings ===
Config ID: global-settings
```


---


## Troubleshooting

**Problem:** Cannot access Jenkins at port 8080

**Solution:**
1. Check security group allows port 8080 from your IP
2. Verify Jenkins is running: `sudo systemctl status jenkins`
3. Check Jenkins logs: `sudo journalctl -u jenkins -n 50`


**Problem:** Initial admin password file not found

**Solution:**
```bash
# Jenkins might still be starting
sudo systemctl status jenkins

# Wait 2-3 minutes, then try again
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```


**Problem:** Plugin installation fails

**Solution:**
1. Check internet connectivity from Jenkins server
2. Try installing plugins one at a time
3. Restart Jenkins: "Manage Jenkins" → "Reload Configuration from Disk"


**Problem:** Tool configuration not saved

**Solution:**
* Make sure to click "Save" button at bottom of page
* Don't navigate away before saving


**Problem:** Credentials not appearing in dropdown

**Solution:**
* Ensure credential ID matches exactly what Jenkinsfile expects
* Check credential scope is "Global"
* Try refreshing the Jenkins page


**Problem:** Cannot connect to SonarQube

**Solution:**
```bash
# Verify SonarQube is running
ssh ubuntu@<SONARQUBE_IP>
docker ps | grep sonar

# Check you can access from Jenkins server using service discovery
curl http://nexus-sonarqube.ultimate-cicd-devops.local:9000
```


---


## Next Steps

Proceed to **Step 7: SonarQube Configuration** (`07-sonarqube-setup.md`)

You will complete SonarQube setup and configure quality gates.


---


**Completion Time:** If all configurations are correct, you spent 30-40 minutes.


**Jenkins is now fully configured for CI/CD pipelines!**


This was the most complex step. The remaining steps are much shorter.
