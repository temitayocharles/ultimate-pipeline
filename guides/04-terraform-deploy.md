# Step 4: Terraform Deployment

**Duration:** 20 minutes (including 5 minutes wait time for deployment)

**Goal:** Deploy all AWS infrastructure using Terraform


---


## What Will Be Created

Terraform will automatically create:

* 5 EC2 instances (t3.medium)
* Security groups with required port rules
* AWS Cloud Map service discovery namespace
* IAM roles and instance profiles
* OIDC provider for GitHub Actions


**Estimated cost while running:** $0.27 per hour


---


## Task 1: Initialize Terraform

Initialize Terraform to download required providers and modules.


### Instructions

**1.1** Navigate to terraform directory:

```bash
cd ~/Documents/PROJECTS/ec2-k8s/terraform
```


**1.2** Initialize Terraform:

```bash
terraform init
```


**Expected output:**
```
Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.x.x...
- Installed hashicorp/aws v5.x.x

Terraform has been successfully initialized!
```


**This process:**
* Downloads the AWS provider plugin
* Prepares the working directory
* Creates a `.terraform` directory (this is normal)


### Verification

**Check that initialization was successful:**

```bash
ls -la
```


**You should see:**
```
drwxr-xr-x  .terraform/
-rw-r--r--  .terraform.lock.hcl
-rw-r--r--  main.tf
-rw-r--r--  variables.tf
... (other .tf files)
```


The `.terraform` directory and `.terraform.lock.hcl` file confirm successful initialization.


---


## Task 2: Validate Configuration

Ensure Terraform configuration files have no syntax errors.


### Instructions

**2.1** Validate the configuration:

```bash
terraform validate
```


**Expected output:**
```
Success! The configuration is valid.
```


**If you see errors:**
* Read the error message carefully
* Check the file and line number mentioned
* Common issues: missing quotes, typos in variable names
* Fix the error and run validate again


### Verification

**No errors should appear.** If validation passes, proceed to next task.


---


## Task 3: Review Deployment Plan

See exactly what Terraform will create before deploying.


### Instructions

**3.1** Generate execution plan:

```bash
terraform plan
```


**This command will:**
* Show all resources to be created
* Display configuration details
* Estimate changes (should show ~30-40 resources to add)


**Expected output summary:**
```
Plan: 35 to add, 0 to change, 0 to destroy.
```


**3.2** Review the plan output carefully.


**Look for these resources:**

```
# EC2 Instances
aws_instance.jenkins_k8s_master
aws_instance.k8s_worker_1
aws_instance.k8s_worker_2
aws_instance.nexus_sonarqube
aws_instance.monitoring

# Security Groups
aws_security_group.jenkins_sg
aws_security_group.k8s_worker_sg
aws_security_group.nexus_sonarqube_sg
aws_security_group.monitoring_sg

# Service Discovery
aws_service_discovery_private_dns_namespace.main
aws_service_discovery_service.jenkins_k8s_master
... (and more)

# IAM Resources
aws_iam_openid_connect_provider.github
aws_iam_role.github_actions
aws_iam_instance_profile.jenkins_k8s_master
aws_iam_instance_profile.k8s_worker
```


**3.3** Verify instance types:

Look for lines showing:
```
instance_type = "t3.medium"
```


**3.4** Verify your SSH key:

Look for lines showing:
```
key_name = "k8s-pipeline-key"
```


If this doesn't match your key name from Step 2, STOP and fix `terraform.auto.tfvars`.


### Verification

**Checklist before proceeding:**

```
[ ] Plan shows approximately 35 resources to add
[ ] All 5 EC2 instances are included
[ ] Security groups are configured
[ ] SSH key name matches yours
[ ] Instance type is t3.medium
[ ] No errors in plan output
```


---


## Task 4: Deploy Infrastructure

Create all AWS resources.


### Instructions

**4.1** Apply the Terraform configuration:

```bash
terraform apply
```


**You will see the plan again, then a prompt:**
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```


**4.2** Type `yes` and press Enter:

```
yes
```


**Deployment will begin. You will see:**
```
aws_security_group.jenkins_sg: Creating...
aws_iam_role.github_actions: Creating...
aws_service_discovery_private_dns_namespace.main: Creating...
...
```


**This process takes approximately 3-5 minutes.**


**Progress indicators you'll see:**
```
aws_instance.jenkins_k8s_master: Still creating... [10s elapsed]
aws_instance.jenkins_k8s_master: Still creating... [20s elapsed]
aws_instance.jenkins_k8s_master: Still creating... [30s elapsed]
...
aws_instance.jenkins_k8s_master: Creation complete after 45s
```


**4.3** Wait for completion.


**Final output:**
```
Apply complete! Resources: 35 added, 0 changed, 0 destroyed.

Outputs:

grafana_url = "http://x.x.x.x:3000"
jenkins_k8s_master_public_ip = "x.x.x.x"
jenkins_url = "http://x.x.x.x:8080"
...
```


### Verification

**Deployment is successful if you see:**
```
Apply complete! Resources: 35 added, 0 changed, 0 destroyed.
```


---


## Task 5: Save Infrastructure Outputs

Save all important information for later use.


### Instructions

**5.1** Display all outputs:

```bash
terraform output
```


**Expected output:**
```
grafana_url = "http://3.88.47.75:3000"
jenkins_k8s_master_private_ip = "172.31.21.117"
jenkins_k8s_master_public_ip = "54.224.153.192"
jenkins_url = "http://54.224.153.192:8080"
k8s_worker_1_private_ip = "172.31.22.233"
k8s_worker_1_public_ip = "54.85.191.80"
... (more outputs)
```


**5.2** Save outputs to a file:

```bash
terraform output > ../terraform-outputs.txt
```


**5.3** View the saved file:

```bash
cat ../terraform-outputs.txt
```


**5.4** Get SSH commands:

```bash
terraform output ssh_commands
```


**Expected output:**
```
{
  "jenkins_k8s_master" = "ssh -i k8s-pipeline-key.pem ubuntu@54.224.153.192"
  "k8s_worker_1" = "ssh -i k8s-pipeline-key.pem ubuntu@54.85.191.80"
  "k8s_worker_2" = "ssh -i k8s-pipeline-key.pem ubuntu@34.228.166.87"
  "monitoring" = "ssh -i k8s-pipeline-key.pem ubuntu@3.88.47.75"
  "nexus_sonarqube" = "ssh -i k8s-pipeline-key.pem ubuntu@98.93.223.228"
}
```


**5.5** Copy these SSH commands to a notes file. You will need them frequently.


### Verification

**Test SSH access to Jenkins master:**

```bash
# Use the SSH command from outputs (replace with YOUR IP)
ssh -i ../k8s-pipeline-key.pem ubuntu@<JENKINS_MASTER_PUBLIC_IP>
```


**If successful, you should see:**
```
Welcome to Ubuntu 24.04 LTS
...
ubuntu@jenkins-k8s-master:~$
```


**Type `exit` to disconnect:**
```bash
exit
```


---


## Task 6: Verify AWS Resources

Confirm all resources were created in AWS Console.


### Instructions

**6.1** Log in to AWS Console: https://console.aws.amazon.com


**6.2** Navigate to EC2 Dashboard


**6.3** Click "Instances" in left sidebar


**You should see 5 running instances:**

```
jenkins-k8s-master         running    t3.medium    <public-ip>
k8s-worker-1               running    t3.medium    <public-ip>
k8s-worker-2               running    t3.medium    <public-ip>
nexus-sonarqube            running    t3.medium    <public-ip>
monitoring                 running    t3.medium    <public-ip>
```


**6.4** Check Security Groups


Click "Security Groups" in left sidebar.


**You should see:**
```
jenkins-sg
k8s-worker-sg  
nexus-sonarqube-sg
monitoring-sg
```


**6.5** Verify Cloud Map Service Discovery


In AWS Console search bar, type "Cloud Map" and open the service.


**You should see:**
* Namespace: `ultimate-cicd-devops.local`
* Services: 5 services registered


### Verification

**All 5 instances should show:**
* State: Running
* Status checks: 2/2 checks passed (wait 2-3 minutes if initializing)


---


## Task 7: Wait for Cloud-Init Completion

EC2 instances run initialization scripts automatically. Wait for them to complete.


### Instructions

**7.1** Wait 5 minutes after terraform apply completes.


Cloud-init is installing:
* Jenkins on master
* Docker on all instances
* Kubernetes components on master and workers
* Nexus and SonarQube on tools instance
* Prometheus and Grafana on monitoring instance


**7.2** Check cloud-init status on Jenkins master:

```bash
# SSH to Jenkins master
ssh -i ../k8s-pipeline-key.pem ubuntu@<JENKINS_MASTER_IP>

# Check cloud-init status
cloud-init status
```


**Expected output when complete:**
```
status: done
```


**If still running:**
```
status: running
```

Wait another 2 minutes and check again.


**7.3** Exit the SSH session:

```bash
exit
```


### Verification

**Cloud-init is complete when:**
* `cloud-init status` shows `done` on all instances
* You can access Jenkins UI at the URL from outputs
* Approximately 5-7 minutes have passed since terraform apply


---


## Task 8: Verify Services Are Running

Check that all services started successfully.


### Instructions

**8.1** Test Jenkins access:

```bash
# Get Jenkins URL from outputs
terraform output jenkins_url
```


**Open in browser:**
```
http://<JENKINS_IP>:8080
```


**You should see:** Jenkins login page (we'll configure this in Step 6)


**8.2** Test SonarQube access:

```bash
# Get SonarQube URL
terraform output sonarqube_url
```


**Open in browser:**
```
http://<SONARQUBE_IP>:9000
```


**You should see:** SonarQube login page


**8.3** Test Nexus access:

```bash
# Get Nexus URL  
terraform output nexus_url
```


**Open in browser:**
```
http://<NEXUS_IP>:8081
```


**You should see:** Nexus welcome page


**8.4** Test Grafana access:

```bash
# Get Grafana URL
terraform output grafana_url
```


**Open in browser:**
```
http://<GRAFANA_IP>:3000
```


**You should see:** Grafana login page


### Verification

**All 4 web interfaces should be accessible:**

```
[ ] Jenkins UI loads at port 8080
[ ] SonarQube UI loads at port 9000  
[ ] Nexus UI loads at port 8081
[ ] Grafana UI loads at port 3000
```


**If any service doesn't load:**
* Wait another 2-3 minutes (cloud-init may still be running)
* Check security group allows your IP
* Verify instance is running in AWS Console


---


## Important Information to Record

**Save these values in a secure note:**

```
=== Public IP Addresses ===
Jenkins Master: <from terraform output>
Worker 1: <from terraform output>
Worker 2: <from terraform output>
Nexus/SonarQube: <from terraform output>
Monitoring: <from terraform output>

=== URLs ===
Jenkins: http://<IP>:8080
SonarQube: http://<IP>:9000
Nexus: http://<IP>:8081
Prometheus: http://<IP>:9090
Grafana: http://<IP>:3000

=== Service Discovery DNS (internal use) ===
jenkins-k8s-master.ultimate-cicd-devops.local
nexus-sonarqube.ultimate-cicd-devops.local
k8s-worker-1.ultimate-cicd-devops.local
monitoring.ultimate-cicd-devops.local

=== AWS Account ===
Account ID: <from aws sts get-caller-identity>
Region: us-east-1
```


---


## Troubleshooting

**Problem:** terraform init fails with "provider not found"

**Solution:** Check internet connection and retry. Terraform needs to download AWS provider.


**Problem:** terraform apply fails with "UnauthorizedOperation"

**Solution:** Verify AWS credentials:
```bash
aws sts get-caller-identity
```


**Problem:** EC2 instances fail to create

**Solution:** Check you haven't exceeded EC2 instance limits in your AWS account. Default limit is 20 instances.


**Problem:** Cannot SSH to instances

**Solution:** 
1. Verify security group allows your IP: `curl ifconfig.me`
2. Update terraform.auto.tfvars with correct IP
3. Run `terraform apply` again to update security group


**Problem:** Services not accessible after 10 minutes

**Solution:**
```bash
# SSH to instance
ssh -i ../k8s-pipeline-key.pem ubuntu@<IP>

# Check cloud-init logs
sudo cat /var/log/cloud-init-output.log

# Look for errors at the end of the file
```


**Problem:** Wrong SSH key name error

**Solution:**
1. Edit terraform.auto.tfvars
2. Update `key_name` to match your AWS key pair
3. Run `terraform apply` again


---


## Rollback (If Needed)

**If deployment fails and you want to start over:**

```bash
terraform destroy
```


Type `yes` when prompted.


This removes all created resources. You can then fix the issue and run `terraform apply` again.


---


## Checklist: Terraform Deployment Complete

Verify before proceeding to Step 5:

```
[ ] Terraform initialization successful
[ ] Terraform plan showed ~35 resources
[ ] Terraform apply completed without errors
[ ] All 5 EC2 instances running in AWS Console
[ ] cloud-init status shows "done" on Jenkins master
[ ] Jenkins UI accessible at http://<IP>:8080
[ ] SonarQube UI accessible at http://<IP>:9000
[ ] Nexus UI accessible at http://<IP>:8081
[ ] Grafana UI accessible at http://<IP>:3000
[ ] SSH access works to Jenkins master
[ ] Terraform outputs saved to file
[ ] Important IPs and URLs recorded in notes
```


---


## Next Steps

Proceed to **Step 5: Kubernetes Initialization** (`05-kubernetes-setup.md`)

You will initialize the Kubernetes cluster and join worker nodes.


---


**Completion Time:** If all checks passed, you spent approximately 20 minutes.


**Your infrastructure is now running!** 

Remember: This costs approximately $0.27 per hour. Use `terraform destroy` when done learning.
