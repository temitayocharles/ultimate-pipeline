# Step 3: Local Environment Setup

**Duration:** 10 minutes

**Goal:** Install required tools and configure project files on your local machine


---


## Task 1: Install Terraform

Terraform is the tool that will create your AWS infrastructure.


### Instructions for macOS

**1.1** Check if Terraform is already installed:

```bash
terraform version
```


**If installed, you should see:**
```
Terraform v1.6.x
```

If you see this, skip to Task 2.


**If not installed, install via Homebrew:**

```bash
# Install Homebrew if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Terraform
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```


**1.2** Verify installation:

```bash
terraform version
```


**Expected output:**
```
Terraform v1.6.x
on darwin_amd64
```


### Instructions for Linux

**1.1** Download and install Terraform:

```bash
wget https://releases.hashicorp.com/terraform/1.6.5/terraform_1.6.5_linux_amd64.zip
unzip terraform_1.6.5_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```


**1.2** Verify installation:

```bash
terraform version
```


### Verification

Run the following command to ensure Terraform can execute:

```bash
terraform -help
```


You should see a list of available commands.


---


## Task 2: Configure Terraform Variables

You need to create a configuration file with your specific values.


### Instructions

**2.1** Navigate to the terraform directory:

```bash
cd ~/Documents/PROJECTS/ec2-k8s/terraform
```


**2.2** Create your configuration file from the example:

```bash
cp terraform.auto.tfvars.example terraform.auto.tfvars
```


**2.3** Open the file in your preferred text editor:

```bash
# Using nano (beginner-friendly)
nano terraform.auto.tfvars

# Or using VS Code
code terraform.auto.tfvars

# Or using vim
vim terraform.auto.tfvars
```


**2.4** Update the following values in the file:


**Find this section:**
```hcl
ssh_config = {
  key_name     = "k8s-pipeline-key"
  allowed_cidr = ["YOUR_IP/32"]
}
```


**Change `YOUR_IP` to your actual IP address from Step 2, Task 5:**

For example, if your IP is `203.0.113.45`, change it to:

```hcl
ssh_config = {
  key_name     = "k8s-pipeline-key"
  allowed_cidr = ["203.0.113.45/32"]
}
```


**Note:** The `/32` means "only this specific IP address". Keep it as is.


**2.5** Find the OIDC configuration section:

```hcl
oidc_config = {
  github_org         = "YOUR_GITHUB_USERNAME"
  github_repo        = "YOUR_REPO_NAME"
  enable_github_oidc = true
}
```


**Change to your actual GitHub details:**

```hcl
oidc_config = {
  github_org         = "temitayocharles"
  github_repo        = "ultimate-pipeline"
  enable_github_oidc = true
}
```


**2.6** Save the file:

* In nano: Press `Ctrl+X`, then `Y`, then `Enter`
* In VS Code: Press `Cmd+S` (Mac) or `Ctrl+S` (Windows/Linux)
* In vim: Press `Esc`, type `:wq`, press `Enter`


**2.7** Verify your changes:

```bash
cat terraform.auto.tfvars | grep -A2 "ssh_config"
cat terraform.auto.tfvars | grep -A3 "oidc_config"
```


**Expected output should show YOUR values, not the placeholders.**


### Verification

**Check the file is properly formatted:**

```bash
cd ~/Documents/PROJECTS/ec2-k8s/terraform
terraform fmt -check terraform.auto.tfvars
```


No output means the file is correctly formatted.


---


## Task 3: Verify Project Structure

Ensure all required files are present.


### Instructions

**3.1** List project structure:

```bash
cd ~/Documents/PROJECTS/ec2-k8s
ls -la
```


**Expected output should include:**
```
drwxr-xr-x   app/
drwxr-xr-x   ci-cd/
drwxr-xr-x   docs/
drwxr-xr-x   guides/
drwxr-xr-x   kubernetes/
drwxr-xr-x   terraform/
-r--------   k8s-pipeline-key.pem
-rw-r--r--   README.md
-rw-r--r--   .github-workflow-example.yml
```


**3.2** Verify terraform directory contents:

```bash
cd terraform
ls -la
```


**Expected output should include:**
```
-rw-r--r--   main.tf
-rw-r--r--   variables.tf
-rw-r--r--   terraform.auto.tfvars
-rw-r--r--   sg.tf
-rw-r--r--   iam.tf
-rw-r--r--   service-discovery.tf
-rw-r--r--   outputs.tf
drwxr-xr-x   scripts/
```


### Verification

**Verify SSH key is accessible:**

```bash
cd ~/Documents/PROJECTS/ec2-k8s
ls -la k8s-pipeline-key.pem
```


**Output should show:**
```
-r--------  1 your-username  staff  1704 Oct 25 10:30 k8s-pipeline-key.pem
```


The permissions `-r--------` are critical for security.


---


## Task 4: Verify Git Configuration

Ensure your repository is properly configured.


### Instructions

**4.1** Check Git status:

```bash
cd ~/Documents/PROJECTS/ec2-k8s
git status
```


**4.2** Verify remote repository:

```bash
git remote -v
```


**Expected output:**
```
origin  https://github.com/temitayocharles/ultimate-pipeline.git (fetch)
origin  https://github.com/temitayocharles/ultimate-pipeline.git (push)
```


**4.3** Ensure you're on the main branch:

```bash
git branch
```


**Expected output:**
```
* main
```


The asterisk indicates you're on the main branch.


### Verification

**Check that terraform.auto.tfvars is gitignored:**

```bash
git status | grep terraform.auto.tfvars
```


**Expected:** No output (file should not appear because it's in .gitignore)

This is correct - we don't want to commit credentials to Git.


---


## Task 5: Test Terraform Installation

Run a basic Terraform command to ensure everything works.


### Instructions

**5.1** Navigate to terraform directory:

```bash
cd ~/Documents/PROJECTS/ec2-k8s/terraform
```


**5.2** Validate Terraform configuration:

```bash
terraform validate
```


**Expected output:**
```
Success! The configuration is valid.
```


**If you see errors about initialization:**

This is normal. We will initialize in the next step. As long as you don't see syntax errors, you're good.


### Verification

**Check Terraform can read your tfvars file:**

```bash
terraform console
```


**At the prompt, type:**
```
var.project_config.name
```


**Expected output:**
```
"ultimate-cicd-devops"
```


**Type `exit` to leave the console.**


This confirms Terraform can read your configuration file correctly.


---


## Checklist: Local Environment Setup Complete

Verify you have completed all tasks:

```
[ ] Terraform installed and version verified
[ ] terraform.auto.tfvars created from example
[ ] Your IP address configured in ssh_config
[ ] Your GitHub details configured in oidc_config
[ ] Project structure verified (all directories present)
[ ] SSH key present with correct permissions (400)
[ ] Git repository configured correctly
[ ] terraform.auto.tfvars properly gitignored
[ ] Terraform can validate configuration files
```


---


## Important Files Location Reference

For quick reference when needed in later steps:

```
SSH Key:
~/Documents/PROJECTS/ec2-k8s/k8s-pipeline-key.pem

Terraform Configuration:
~/Documents/PROJECTS/ec2-k8s/terraform/terraform.auto.tfvars

Terraform Directory:
~/Documents/PROJECTS/ec2-k8s/terraform/

Application Code:
~/Documents/PROJECTS/ec2-k8s/app/

Kubernetes Manifests:
~/Documents/PROJECTS/ec2-k8s/kubernetes/

Jenkins Pipeline:
~/Documents/PROJECTS/ec2-k8s/ci-cd/Jenkinsfile
```


---


## Troubleshooting

**Problem:** Terraform not found after installation

**Solution:** Close and reopen your terminal, then try again


**Problem:** Permission denied when running terraform

**Solution:** Ensure Terraform is executable:
```bash
chmod +x /usr/local/bin/terraform
```


**Problem:** Cannot save terraform.auto.tfvars

**Solution:** Check you have write permissions in the directory:
```bash
ls -la ~/Documents/PROJECTS/ec2-k8s/terraform/
```


**Problem:** terraform.auto.tfvars appears in git status

**Solution:** Verify .gitignore exists and contains `*.tfvars`:
```bash
cat ~/Documents/PROJECTS/ec2-k8s/.gitignore | grep tfvars
```


---


## Next Steps

Proceed to **Step 4: Terraform Deployment** (`04-terraform-deploy.md`)

You will deploy the complete infrastructure to AWS.


---


**Completion Time:** If you completed all tasks, you should have spent approximately 10 minutes.


**Ready to deploy?** Ensure all checkboxes above are marked before proceeding.
