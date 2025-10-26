# Step 8: Nexus Configuration

**Duration:** 15-20 minutes

**Goal:** Configure Nexus Repository Manager for storing Maven artifacts


---


## What You Will Do

* Access Nexus Repository Manager
* Get initial admin password
* Complete setup wizard
* Create/verify Maven repositories
* Enable artifact redeployment
* Test connection


---


## Task 1: Access Nexus

Log in to Nexus for the first time.


### Instructions

**1.1** Open Nexus in your browser:

```
http://<NEXUS_SONARQUBE_PUBLIC_IP>:8081
```


**Note:** Nexus runs on port 8081 (SonarQube is on 9000).


**1.2** You should see the Nexus Repository Manager welcome page.


**1.3** Click "Sign In" (top right corner).


### Verification

**You should see:** A login dialog asking for username and password.


---


## Task 2: Get Initial Admin Password

Retrieve the default admin password from the server.


### Instructions

**2.1** SSH to the Nexus/SonarQube server:

```bash
ssh -i k8s-pipeline-key.pem ubuntu@<NEXUS_SONARQUBE_PUBLIC_IP>
```


**2.2** Get the Nexus admin password from the container:

```bash
docker exec nexus cat /nexus-data/admin.password
```


**Expected output:** A password like:

```
7c4e8d92-3b1a-4f5c-9e2d-8a6b3c1e5f7g
```


**2.3** Copy this password.


**2.4** Keep the SSH session open (we'll need it later).


### Verification

**You have:** The initial admin password copied.


---


## Task 3: Complete Setup Wizard

Configure Nexus for the first time.


### Instructions

**3.1** Back in the browser, enter credentials:

```
Username: admin
Password: <paste the password from previous task>
```


**3.2** Click "Sign In".


**3.3** The setup wizard will start. You'll see "Setup" page.


**3.4** Click "Next".


**3.5** On "New password" page, set a new admin password:

```
New password: admin123
Confirm password: admin123
```


**IMPORTANT:** We use `admin123` because it's already configured in Jenkins Maven settings (from Step 6, Task 15).


**3.6** Click "Next".


**3.7** On "Configure Anonymous Access" page:

**Select:** "Enable anonymous access"


**Why:** Allows Maven to download dependencies without authentication.


**3.8** Click "Next".


**3.9** Click "Finish".


### Verification

**You should see:** Nexus dashboard with repositories listed.


---


## Task 4: Verify Maven Repositories Exist

Check that required repositories are already created.


### Instructions

**4.1** Click the "gear" icon (⚙️) in the top menu (Server administration).


**4.2** Click "Repositories" (left sidebar under "Repository" section).


**4.3** You should see these repositories:

```
Name                    Type     Format
maven-central          proxy    maven2
maven-public           group    maven2
maven-releases         hosted   maven2
maven-snapshots        hosted   maven2
nuget-group            group    nuget
nuget-hosted           hosted   nuget
nuget.org-proxy        proxy    nuget
```


**The important ones for our pipeline:**

* **maven-releases**: Stores final release artifacts (version without SNAPSHOT)
* **maven-snapshots**: Stores development snapshots (version with SNAPSHOT)
* **maven-public**: Groups all Maven repositories together


**If these repositories exist:** Great! Nexus comes with them by default.


**If they don't exist:** You'll need to create them (see Troubleshooting section).


### Verification

**You can see:** `maven-releases` and `maven-snapshots` repositories in the list.


---


## Task 5: Enable Redeployment for Snapshots

Allow overwriting snapshot artifacts during development.


### Instructions

**5.1** From the repositories list, click on `maven-snapshots`.


**5.2** Scroll down to "Hosted" section.


**5.3** Find "Deployment policy" setting.


**5.4** Change it to:

```
Deployment policy: Allow redeploy
```


**Why:** During development, you'll build the same SNAPSHOT version multiple times. This allows overwriting.


**5.5** Scroll to bottom and click "Save".


**5.6** Go back to repositories list (click "Repositories" in left sidebar).


**5.7** Click on `maven-releases`.


**5.8** Scroll to "Deployment policy".


**5.9** Keep it as:

```
Deployment policy: Disable redeploy
```


**Why:** Release versions should be immutable. Once published, they cannot be changed.


**5.10** Verify it's set to "Disable redeploy" and click "Save" if you changed anything.


### Verification

**Configuration:**
* maven-snapshots: Allow redeploy ✓
* maven-releases: Disable redeploy ✓


---


## Task 6: Get Repository URLs

Record the URLs needed for Maven configuration.


### Instructions

**6.1** From repositories list, click on `maven-releases`.


**6.2** Copy the URL shown:

```
http://<internal-ip>:8081/repository/maven-releases/
```


**For our setup, the correct URL using service discovery is:**

```
http://nexus-sonarqube.ultimate-cicd-devops.local:8081/repository/maven-releases/
```


**6.3** Go back and click on `maven-snapshots`.


**6.4** Copy the URL:

```
http://nexus-sonarqube.ultimate-cicd-devops.local:8081/repository/maven-snapshots/
```


**Note:** These URLs are already configured in your `app/pom.xml` file from the compatibility fixes.


### Verification

**You have recorded:**
* maven-releases URL
* maven-snapshots URL


---


## Task 7: Test Nexus Connection from Jenkins Server

Verify Jenkins can reach Nexus via service discovery.


### Instructions

**7.1** In your SSH session to Nexus server, exit:

```bash
exit
```


**7.2** SSH to Jenkins master:

```bash
ssh -i k8s-pipeline-key.pem ubuntu@<JENKINS_MASTER_PUBLIC_IP>
```


**7.3** Test DNS resolution:

```bash
ping -c 3 nexus-sonarqube.ultimate-cicd-devops.local
```


**Expected output:** Successful pings showing the private IP.


**7.4** Test HTTP connection to Nexus:

```bash
curl -I http://nexus-sonarqube.ultimate-cicd-devops.local:8081
```


**Expected output:**

```
HTTP/1.1 200 OK
Server: Nexus/3.x
...
```


**7.5** Test authentication with new password:

```bash
curl -u admin:admin123 \
  http://nexus-sonarqube.ultimate-cicd-devops.local:8081/service/rest/v1/status
```


**Expected output:** JSON with status information:

```json
{
  "available": true
}
```


**7.6** Exit SSH session:

```bash
exit
```


### Verification

**Jenkins can connect to Nexus** using service discovery DNS and authenticate with admin credentials.


---


## Task 8: Verify Maven Settings in Jenkins

Confirm Jenkins has correct Nexus credentials.


### Instructions

**8.1** Open Jenkins in browser:

```
http://<JENKINS_MASTER_PUBLIC_IP>:8080
```


**8.2** Click "Manage Jenkins" → "Managed files".


**8.3** Click on "global-settings" (the Maven settings file you created in Step 6).


**8.4** Verify the content has:

```xml
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
```


**The username and password must match what you set in Nexus (admin/admin123).**


**If they don't match:**

1. Click "Edit"
2. Update the password to `admin123`
3. Click "Save"


### Verification

**Jenkins Maven settings** have correct Nexus credentials (admin/admin123).


---


## Checklist: Nexus Setup Complete

Verify all configurations:

```
[ ] Nexus accessible at http://<IP>:8081
[ ] Initial admin password retrieved from container
[ ] Admin password changed to admin123
[ ] Anonymous access enabled
[ ] maven-releases repository exists
[ ] maven-snapshots repository exists
[ ] maven-snapshots allows redeployment
[ ] maven-releases disables redeployment
[ ] Repository URLs recorded
[ ] Service discovery DNS working from Jenkins
[ ] Maven settings in Jenkins have correct credentials (admin/admin123)
```


---


## Important Information to Record

**Add to your notes:**

```
=== Nexus Access ===
URL: http://<IP>:8081
Username: admin
Password: admin123

=== Repository URLs ===
Releases: http://nexus-sonarqube.ultimate-cicd-devops.local:8081/repository/maven-releases/
Snapshots: http://nexus-sonarqube.ultimate-cicd-devops.local:8081/repository/maven-snapshots/

=== Repository Policies ===
maven-releases: Disable redeploy (immutable)
maven-snapshots: Allow redeploy (development)

=== Integration ===
Credentials in Jenkins Maven settings: admin/admin123
Repository IDs: maven-releases, maven-snapshots
```


---


## Troubleshooting

**Problem:** Cannot access Nexus at port 8081

**Solution:**
```bash
# SSH to server
ssh ubuntu@<IP>

# Check if Nexus container is running
docker ps | grep nexus

# If not running, start it
docker start nexus

# Check logs
docker logs nexus

# Nexus takes 1-2 minutes to start fully
```


**Problem:** Initial admin password file not found

**Solution:**
```bash
# Check if file exists
docker exec nexus ls -la /nexus-data/admin.password

# If it doesn't exist, Nexus has already been initialized
# Try default password: admin123
# Or reset Nexus by recreating the container
```


**Problem:** Cannot save repository configuration

**Solution:**
1. Make sure you're logged in as admin
2. Check you have permission to modify settings
3. Try refreshing the page and signing in again


**Problem:** Maven build cannot connect to Nexus

**Solution:**
```bash
# Verify service discovery from Jenkins server
ssh ubuntu@<JENKINS_IP>
curl http://nexus-sonarqube.ultimate-cicd-devops.local:8081

# Check credentials in Jenkins global-settings match Nexus
# Username: admin
# Password: admin123
```


**Problem:** "401 Unauthorized" when deploying artifacts

**Solution:**
1. Verify Nexus credentials: admin/admin123
2. Check Jenkins Maven settings have correct password
3. Ensure repository IDs in pom.xml match Nexus repository names


**Problem:** Need to create maven-releases or maven-snapshots repository manually

**Solution:**
1. In Nexus, click ⚙️ → Repositories → Create repository
2. Select "maven2 (hosted)"
3. For maven-releases:
   ```
   Name: maven-releases
   Version policy: Release
   Deployment policy: Disable redeploy
   ```
4. For maven-snapshots:
   ```
   Name: maven-snapshots
   Version policy: Snapshot
   Deployment policy: Allow redeploy
   ```
5. Click "Create repository"


---


## Next Steps

Proceed to **Step 9: Create and Run Pipeline** (`09-pipeline-setup.md`)

You will create the Jenkins pipeline job and run your first build!


---


**Completion Time:** You should have spent 15-20 minutes on Nexus setup.


**Nexus is ready to store your Maven artifacts!**
