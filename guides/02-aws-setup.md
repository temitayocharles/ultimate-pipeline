# Step 2: AWS Account Setup

**Duration:** 15 minutes

**Goal:** Configure your AWS account and create required resources for infrastructure deployment


---


## Prerequisites

* Active AWS account
* Credit card on file with AWS
* Email access for verification


---


## Task 1: Create SSH Key Pair

An SSH key pair is required to access your EC2 instances securely.


### Instructions

**1.1** Log in to AWS Console at https://console.aws.amazon.com


**1.2** In the top-right corner, verify you are in the **us-east-1** region (N. Virginia)

If not, click the region dropdown and select **US East (N. Virginia) us-east-1**


**1.3** In the search bar at the top, type **EC2** and click on the EC2 service


**1.4** In the left sidebar, scroll down and click **Key Pairs** (under Network & Security section)


**1.5** Click the orange **Create key pair** button


**1.6** Fill in the form:

```
Name: k8s-pipeline-key

Key pair type: Select "RSA"

Private key file format: Select ".pem"
```


**1.7** Click **Create key pair**


**1.8** Your browser will automatically download a file named `k8s-pipeline-key.pem`


**1.9** Move this file to your project directory:

```bash
# Open terminal and navigate to your project
cd ~/Documents/PROJECTS/ec2-k8s

# Move the downloaded key file here (adjust path if your Downloads folder is different)
mv ~/Downloads/k8s-pipeline-key.pem .

# Set correct permissions (very important!)
chmod 400 k8s-pipeline-key.pem

# Verify the file exists
ls -la k8s-pipeline-key.pem
```


**Expected output:**
```
-r--------  1 user  staff  1704 Oct 25 10:30 k8s-pipeline-key.pem
```

Note the permissions starting with `-r--------` which means read-only for owner.


### Verification

**Verify the key pair exists in AWS:**

* In EC2 console, click **Key Pairs** in left sidebar
* You should see `k8s-pipeline-key` listed
* Status should show as **Available**


---


## Task 2: Configure AWS CLI

The AWS Command Line Interface allows Terraform to interact with your AWS account.


### Instructions

**2.1** Check if AWS CLI is already installed:

```bash
aws --version
```


**Expected output (if installed):**
```
aws-cli/2.13.x Python/3.11.x Darwin/23.x.x
```


**If not installed, install it:**

**For macOS:**
```bash
brew install awscli
```


**For Linux:**
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```


**2.2** Configure AWS credentials

You need an Access Key ID and Secret Access Key from AWS.


**To create access keys:**

1. In AWS Console, click your name in top-right corner
2. Click **Security Credentials**
3. Scroll down to **Access keys** section
4. Click **Create access key**
5. Select **Command Line Interface (CLI)**
6. Check the confirmation box
7. Click **Next**
8. Optionally add a description tag: "Terraform CLI"
9. Click **Create access key**
10. **IMPORTANT:** Copy both the Access Key ID and Secret Access Key
    * Click **Download .csv file** to save them securely
    * You will not be able to see the secret key again


**2.3** Run AWS configuration:

```bash
aws configure
```


**You will be prompted for 4 values. Enter them as follows:**

```
AWS Access Key ID [None]: <paste your Access Key ID>
AWS Secret Access Key [None]: <paste your Secret Access Key>
Default region name [None]: us-east-1
Default output format [None]: json
```


**2.4** Verify configuration:

```bash
aws sts get-caller-identity
```


**Expected output:**
```json
{
    "UserId": "AIDAXXXXXXXXXXXXXXXXX",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/your-username"
}
```


Your account number will be different. This confirms AWS CLI is configured correctly.


### Verification

**Test AWS access:**

```bash
aws ec2 describe-regions --region us-east-1
```


This should return a list of AWS regions without errors.


---


## Task 3: Set Billing Alerts

Important: Set up billing alerts to avoid unexpected charges.


### Instructions

**3.1** In AWS Console, click your account name in top-right corner


**3.2** Click **Billing and Cost Management**


**3.3** In the left sidebar, click **Budgets**


**3.4** Click **Create budget**


**3.5** Select **Customize (advanced)** and click **Next**


**3.6** Configure budget:

```
Budget name: DevOps-Learning-Budget

Period: Monthly

Budget renewal type: Recurring budget

Start month: <current month>

Budgeting method: Fixed

Enter your budgeted amount: $50.00
```


**3.7** Click **Next**


**3.8** Click **Add an alert threshold**


**3.9** Configure alert:

```
Threshold: 80 %

Email contacts: <your email address>
```


**3.10** Click **Next**, review, and click **Create budget**


**3.11** Check your email and confirm the SNS subscription


### Verification

* You should see your budget listed in the Budgets dashboard
* You should receive a confirmation email from AWS Notifications


---


## Task 4: Verify IAM Permissions

Your AWS user needs specific permissions to create resources.


### Instructions

**4.1** In AWS Console, search for **IAM** and open the service


**4.2** Click **Users** in the left sidebar


**4.3** Click on your username


**4.4** Check the **Permissions** tab


**Required permissions (minimum):**

* AmazonEC2FullAccess
* IAMFullAccess
* AmazonVPCFullAccess
* CloudWatchLogsFullAccess


**If you have AdministratorAccess, you have all required permissions.**


**If you are missing permissions:**

1. Ask your AWS administrator to grant them
2. Or attach the policies listed above to your user


### Verification

```bash
aws ec2 describe-vpcs
```


This should return information about your VPCs without permission errors.


---


## Task 5: Get Your Public IP Address

Your IP address is needed for SSH security group rules.


### Instructions

**5.1** Run this command:

```bash
curl ifconfig.me
```


**Expected output:**
```
203.0.113.45
```

This is your public IPv4 address.


**5.2** Write down this IP address. You will need it in Step 3.


**If the command returns an IPv6 address (contains colons):**

```bash
curl -4 ifconfig.me
```

The `-4` flag forces IPv4.


### Verification

* Your IP should be in format: `XXX.XXX.XXX.XXX` (four numbers separated by dots)
* Each number should be between 0 and 255


---


## Task 6: Create Docker Hub Account

Docker Hub stores your container images.


### Instructions

**6.1** Go to https://hub.docker.com/signup


**6.2** Fill in the registration form:

```
Docker ID: <choose a username>
Email: <your email>
Password: <choose a strong password>
```


**6.3** Click **Sign Up**


**6.4** Verify your email address by clicking the link sent to your inbox


**6.5** Log in to Docker Hub


**6.6** Write down your Docker Hub username and password


You will need these credentials in Step 6 (Jenkins Configuration).


### Verification

* You should be able to log in at https://hub.docker.com
* Your dashboard should be empty (no repositories yet)


---


## Checklist: AWS Setup Complete

Verify you have completed all tasks:

```
[ ] SSH key pair created (k8s-pipeline-key)
[ ] SSH key file downloaded to project directory
[ ] SSH key permissions set to 400
[ ] AWS CLI installed and configured
[ ] AWS credentials verified with `aws sts get-caller-identity`
[ ] Billing alert configured ($50 threshold)
[ ] IAM permissions verified
[ ] Public IP address recorded
[ ] Docker Hub account created and verified
```


---


## Important Information to Save

**Record these values in a secure note:**

```
AWS Region: us-east-1
SSH Key Name: k8s-pipeline-key
Your Public IP: <from Task 5>
Docker Hub Username: <from Task 6>
Docker Hub Password: <from Task 6>
AWS Account ID: <from aws sts get-caller-identity>
```


You will need this information in later steps.


---


## Troubleshooting

**Problem:** AWS CLI commands return "Unable to locate credentials"

**Solution:** Run `aws configure` again and re-enter your access keys


**Problem:** SSH key download fails

**Solution:** Disable popup blockers in your browser and try creating the key pair again


**Problem:** Cannot set billing alert

**Solution:** Billing alerts require root account access. If using IAM user, ask your administrator


**Problem:** `curl ifconfig.me` returns nothing

**Solution:** Try `curl icanhazip.com` or `dig +short myip.opendns.com @resolver1.opendns.com`


---


## Next Steps

Proceed to **Step 3: Local Environment Setup** (`03-local-setup.md`)

You will configure your local development environment and project files.


---


**Completion Time:** If you completed all tasks, you should have spent approximately 15 minutes.
