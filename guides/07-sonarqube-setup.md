# Step 7: SonarQube Configuration

**Duration:** 10-15 minutes

**Goal:** Complete SonarQube setup and verify integration with Jenkins


---


## What You Will Do

* Log in to SonarQube
* Change default password
* Verify token created in previous step
* Configure quality gates (optional)
* Test connection from Jenkins


---


## Task 1: Access SonarQube

Log in to SonarQube for the first time.


### Instructions

**1.1** Open SonarQube in your browser:

```
http://<NEXUS_SONARQUBE_PUBLIC_IP>:9000
```


**1.2** You should see the SonarQube login page.


**1.3** Log in with default credentials:

```
Username: admin
Password: admin
```


**1.4** SonarQube will immediately ask you to change the password.


**1.5** Set a new password:

```
Old password: admin
New password: <choose a strong password>
Confirm password: <same password>
```


**Write down your new password!**


**1.6** Click "Update".


### Verification

**You should see:** SonarQube dashboard with "Welcome" message.


---


## Task 2: Verify Authentication Token

Check that the token you created in Step 6 exists.


### Instructions

**2.1** Click on the "A" icon (top right corner).


**2.2** Select "My Account" from dropdown.


**2.3** Click "Security" tab.


**2.4** In the "Tokens" section, you should see:

```
Name: jenkins-token
Type: Global Analysis Token
Created: <today's date>
```


**If you DON'T see the token:**

**Create it now:**

1. In "Generate Tokens" section, enter:
   ```
   Name: jenkins-token
   Type: Global Analysis Token
   Expires in: No expiration
   ```

2. Click "Generate"

3. Copy the token immediately (looks like `squ_...`)

4. Go back to Jenkins → Manage Jenkins → Credentials

5. Find "sonar-token" credential and update it with new token


### Verification

**You should have:** A valid token named "jenkins-token" in SonarQube.


---


## Task 3: Test SonarQube Connection from Jenkins

Verify Jenkins can communicate with SonarQube.


### Instructions

**3.1** Open Jenkins in another browser tab:

```
http://<JENKINS_MASTER_PUBLIC_IP>:8080
```


**3.2** Log in with your Jenkins admin credentials.


**3.3** Click "Manage Jenkins" → "System".


**3.4** Scroll to "SonarQube servers" section.


**3.5** You should see:

```
Name: sonar
Server URL: http://nexus-sonarqube.ultimate-cicd-devops.local:9000
Server authentication token: sonar-token
```


**3.6** Click "Test Connection" button (if available).


**Expected result:** "Connection successful" or similar message.


**If there's no test button:**

Don't worry, we'll verify the connection when we run the pipeline in Step 9.


### Verification

**SonarQube server is configured in Jenkins** and ready to analyze code.


---


## Task 4: Review Default Quality Gate (Optional)

Understand SonarQube quality standards.


### Instructions

**4.1** In SonarQube, click "Quality Gates" (top menu).


**4.2** You should see "Sonar way" quality gate (the default).


**4.3** Click on "Sonar way" to view its conditions:

```
Conditions checked:
- Coverage on New Code < 80%
- Duplicated Lines on New Code > 3%
- Maintainability Rating on New Code worse than A
- Reliability Rating on New Code worse than A
- Security Hotspots Reviewed on New Code < 100%
- Security Rating on New Code worse than A
```


**What this means:**

Your code will be analyzed against these standards. If any condition fails, the quality gate fails, and the Jenkins pipeline will stop.


**For learning purposes, you can make the quality gate less strict:**

**4.4** Click "Copy" to create a custom quality gate.


**4.5** Name it: `relaxed-gate`


**4.6** Remove or adjust conditions to be less strict (for example, set coverage to 50% instead of 80%).


**4.7** Click "Set as Default" to use this quality gate for all projects.


**Note:** This step is optional. The default "Sonar way" quality gate is fine for learning.


### Verification

**You understand:** SonarQube will analyze your code and enforce quality standards.


---


## Task 5: Verify Service Discovery DNS (Advanced)

Confirm SonarQube is accessible via service discovery name.


### Instructions

**5.1** SSH to Jenkins master:

```bash
ssh -i k8s-pipeline-key.pem ubuntu@<JENKINS_MASTER_PUBLIC_IP>
```


**5.2** Test DNS resolution:

```bash
ping -c 3 nexus-sonarqube.ultimate-cicd-devops.local
```


**Expected output:**

```
PING nexus-sonarqube.ultimate-cicd-devops.local (10.x.x.x) 56(84) bytes of data.
64 bytes from ip-10-x-x-x: icmp_seq=1 ttl=64 time=0.5 ms
64 bytes from ip-10-x-x-x: icmp_seq=2 ttl=64 time=0.4 ms
64 bytes from ip-10-x-x-x: icmp_seq=3 ttl=64 time=0.3 ms
```


**5.3** Test HTTP connection:

```bash
curl -I http://nexus-sonarqube.ultimate-cicd-devops.local:9000
```


**Expected output:**

```
HTTP/1.1 200 OK
Server: nginx
Content-Type: text/html
...
```


**5.4** Exit SSH session:

```bash
exit
```


### Verification

**Service discovery DNS is working** and Jenkins can reach SonarQube using the internal DNS name.


---


## Checklist: SonarQube Setup Complete

Verify all tasks before proceeding:

```
[ ] SonarQube accessible at http://<IP>:9000
[ ] Default admin password changed
[ ] New SonarQube password saved in your notes
[ ] Authentication token exists (jenkins-token)
[ ] Token saved in Jenkins as "sonar-token" credential
[ ] SonarQube server configured in Jenkins (name: sonar)
[ ] Service discovery DNS working (optional verification)
[ ] Quality gate reviewed (optional configuration)
```


---


## Important Information to Record

**Add to your notes:**

```
=== SonarQube Access ===
URL: http://<IP>:9000
Username: admin
Password: <your new password>

=== Integration with Jenkins ===
Token Name: jenkins-token
Token ID in Jenkins: sonar-token
Server Name in Jenkins: sonar
Server URL: http://nexus-sonarqube.ultimate-cicd-devops.local:9000

=== Quality Gate ===
Default: Sonar way
Custom: <if you created one>
```


---


## Troubleshooting

**Problem:** Cannot access SonarQube at port 9000

**Solution:**
```bash
# SSH to Nexus/SonarQube server
ssh ubuntu@<SONARQUBE_IP>

# Check if SonarQube container is running
docker ps | grep sonar

# If not running, check logs
docker logs sonarqube

# Restart if needed
docker restart sonarqube
```


**Problem:** "Unauthorized" error when testing connection from Jenkins

**Solution:**
1. Verify the token is correct in Jenkins credentials
2. Generate a new token in SonarQube
3. Update the "sonar-token" credential in Jenkins with new token


**Problem:** Service discovery DNS not resolving

**Solution:**
```bash
# Check Cloud Map service
aws servicediscovery list-services --region us-east-1

# Verify the instance is registered
aws servicediscovery list-instances \
  --service-id <service-id> \
  --region us-east-1

# DNS may take 30-60 seconds to propagate after instance starts
```


**Problem:** Quality gate too strict, builds failing

**Solution:**
1. Create a custom quality gate with relaxed conditions
2. Set it as default
3. Or disable quality gate check temporarily in Jenkinsfile


---


## Next Steps

Proceed to **Step 8: Nexus Configuration** (`08-nexus-setup.md`)

You will set up Nexus repository for Maven artifacts.


---


**Completion Time:** You should have spent 10-15 minutes on SonarQube setup.


**SonarQube is ready to analyze your code quality!**
