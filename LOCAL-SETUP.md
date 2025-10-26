# Local Development Setup

> **Note:** This guide explains how to work with your personal AWS configuration while keeping sensitive data out of the public repository.

---

## Overview

This repository uses **template files** with placeholders for AWS resources. To work locally, you'll create `.personal` versions of sensitive files that Git will ignore.

### Files That Need Personal Configuration

- `terraform/backend.tf.personal` - Your actual S3 bucket configuration
- `BACKEND-SETUP.personal.md` - Documentation with your bucket details

---

## Quick Start

### Step 1: Copy Personal Configuration Files

If you already have the `.personal` files (backed up locally):

```bash
# These files should already exist in your local workspace
ls -la terraform/backend.tf.personal
ls -la BACKEND-SETUP.personal.md
```

### Step 2: Use Your Personal Backend

When working locally, reference your `.personal` files:

```bash
# Copy your personal backend to the active config
cp terraform/backend.tf.personal terraform/backend.tf

# Initialize Terraform with your actual bucket
cd terraform/
terraform init
```

**Important:** Don't commit `terraform/backend.tf` if it contains your personal bucket name!

### Step 3: Before Committing

Always use the template version before committing:

```bash
# Check what you're about to commit
git status

# If backend.tf shows as modified, restore the template:
git restore terraform/backend.tf

# Or manually ensure it uses placeholders
```

---

## Creating Personal Files (First Time)

If you don't have `.personal` files yet:

### 1. Create Personal Backend Configuration

```bash
# Copy template
cp terraform/backend.tf terraform/backend.tf.personal

# Edit with your bucket name
nano terraform/backend.tf.personal
```

Uncomment and configure the backend block:

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-YOUR-NAME-k8s-XXXXX"  # Your actual bucket
    key            = "ec2-k8s/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### 2. Create Personal Documentation

```bash
# Copy template
cp BACKEND-SETUP.md BACKEND-SETUP.personal.md

# Edit with your specific details
nano BACKEND-SETUP.personal.md
```

Update the following sections:
- Status: Change from "SETUP REQUIRED" to "CONFIGURED"
- Bucket Name: Your actual S3 bucket name
- Date: When you created the resources
- Any example commands with your actual bucket name

---

## Workflow

### Daily Development

```bash
# 1. Ensure you're using your personal backend
cp terraform/backend.tf.personal terraform/backend.tf

# 2. Work normally
cd terraform/
terraform plan
terraform apply

# 3. Before committing ANY changes
cd ..
git restore terraform/backend.tf  # Reset to template
git status  # Verify no sensitive data

# 4. Commit only template files
git add <your-files>
git commit -m "Your changes"
git push
```

### Protected Files (.gitignore)

These patterns prevent personal data from being committed:

```gitignore
# Personal configuration files (keep local, don't push upstream)
*.personal
*.personal.*
BACKEND-SETUP.personal.md
terraform/backend.tf.personal
```

---

## Verification

### Check What Will Be Committed

```bash
# See what's staged
git diff --cached

# Search for your bucket name (should return nothing)
git diff --cached | grep "terraform-state-YOUR-NAME"

# Search for your AWS account ID (should return nothing)
git diff --cached | grep "123456789012"
```

### Verify Gitignore Works

```bash
# These should NOT appear in git status
git status | grep "\.personal"  # Should be empty

# These files should be untracked
git ls-files --others --exclude-standard | grep personal
```

---

## Safety Checklist

Before pushing to GitHub:

- [ ] `terraform/backend.tf` uses template placeholders (YOUR-UNIQUE-BUCKET-NAME)
- [ ] `BACKEND-SETUP.md` doesn't contain your actual bucket name
- [ ] No AWS account IDs in committed files
- [ ] `.gitignore` includes `*.personal*` patterns
- [ ] `git status` shows no `.personal` files
- [ ] `git diff` shows no sensitive data

---

## Recovering Your Configuration

If you lose your `.personal` files:

### Reconstruct Backend Configuration

1. **Find Your S3 Bucket:**
   ```bash
   aws s3 ls | grep terraform-state
   ```

2. **Find Your DynamoDB Table:**
   ```bash
   aws dynamodb list-tables | grep terraform-state-lock
   ```

3. **Recreate backend.tf.personal:**
   ```bash
   cp terraform/backend.tf terraform/backend.tf.personal
   # Edit and add your actual bucket name
   ```

### Verify Configuration

```bash
cd terraform/
terraform init
# Should connect to your existing state
```

---

## Team Collaboration

### Sharing Templates (Safe)

These files are safe to commit and push:

- `terraform/backend.tf` (with placeholders)
- `BACKEND-SETUP.md` (generic instructions)
- All guides with example data
- `.gitignore` (with personal file exclusions)

### Never Share (Personal)

These files should NEVER be committed:

- `terraform/backend.tf.personal`
- `BACKEND-SETUP.personal.md`
- Any file with your actual AWS credentials
- Files with your AWS account ID
- Files with your S3 bucket names

---

## Troubleshooting

### "Backend configuration changed"

**Cause:** You switched between template and personal backend

**Solution:**
```bash
cd terraform/
terraform init -reconfigure
```

### "Error: Failed to get existing workspaces"

**Cause:** Using template backend (commented out)

**Solution:**
```bash
cp terraform/backend.tf.personal terraform/backend.tf
terraform init
```

### "Accidentally committed personal file"

**Solution:**
```bash
# Remove from staging
git reset HEAD terraform/backend.tf.personal

# Ensure it's in .gitignore
echo "terraform/backend.tf.personal" >> .gitignore
```

---

## Summary

**Keep Separate:** Template files (public) vs Personal files (local)  
**Use .personal suffix:** For all sensitive configurations  
**Always verify:** Check git status before pushing  
**Follow workflow:** Copy personal → work → restore template → commit  
**Protected by .gitignore:** Personal files can't be accidentally committed

**Remember:** Your `.personal` files contain YOUR AWS resources. The template files help others set up THEIR resources.
