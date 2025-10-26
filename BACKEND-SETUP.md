# Terraform Backend Configuration

**Status:** 🔧 SETUP REQUIRED  
**Type:** Template - Configure with your AWS resources

> ⚠️ **IMPORTANT:** This is a template document. You must create your own S3 bucket and DynamoDB table before using remote state.

---

## Overview

This project uses Terraform remote state with:
- **S3** for state file storage
- **DynamoDB** for state locking (prevents concurrent modifications)

### Benefits
- ✅ Team collaboration on infrastructure
- ✅ State versioning and backup
- ✅ Prevents concurrent modifications
- ✅ Secure state encryption

---

## Setup Instructions

### Step 1: Create S3 Bucket

Choose a globally unique bucket name (suggested format: `terraform-state-<yourname>-<project>-<random>`):

```bash
# Replace YOUR-UNIQUE-BUCKET-NAME with your chosen name
aws s3api create-bucket \
  --bucket YOUR-UNIQUE-BUCKET-NAME \
  --region us-east-1
```

**Example:** `terraform-state-alice-k8s-98765`

### Step 2: Enable Bucket Versioning

```bash
aws s3api put-bucket-versioning \
  --bucket YOUR-UNIQUE-BUCKET-NAME \
  --versioning-configuration Status=Enabled
```

### Step 3: Enable Bucket Encryption

```bash
aws s3api put-bucket-encryption \
  --bucket YOUR-UNIQUE-BUCKET-NAME \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
```

### Step 4: Create DynamoDB Table

```bash
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### Step 5: Configure Backend

1. Open `terraform/backend.tf`
2. Uncomment the backend block
3. Replace `YOUR-UNIQUE-BUCKET-NAME-HERE` with your actual bucket name
4. Save the file

**Recommended:** Create a `backend.tf.personal` file with your configuration and add it to `.gitignore` to keep your bucket name private.

### Step 6: Initialize Terraform

```bash
cd terraform/
terraform init
```

If you have existing local state, Terraform will ask to migrate it to S3.

---

## Verification

### Verify S3 Bucket

```bash
# List your S3 buckets
aws s3 ls | grep terraform-state

# Check bucket versioning
aws s3api get-bucket-versioning --bucket YOUR-UNIQUE-BUCKET-NAME

# Check bucket encryption
aws s3api get-bucket-encryption --bucket YOUR-UNIQUE-BUCKET-NAME
```

### Verify DynamoDB Table

```bash
aws dynamodb describe-table --table-name terraform-state-lock \
  --query 'Table.[TableName,TableStatus,BillingModeSummary.BillingMode]' \
  --output table
```

### Verify Terraform Backend

```bash
cd terraform/
terraform init
# Should show: "Successfully configured the backend "s3"!"

# Check state list
terraform state list
```

---

## Resources Created

After completing setup, you'll have:

### S3 Bucket for State Storage
- **Bucket Name:** `YOUR-UNIQUE-BUCKET-NAME`
- **Region:** `us-east-1`
- **Versioning:** ✅ Enabled
- **Encryption:** ✅ AES-256 (Server-Side)
- **Purpose:** Stores Terraform state files remotely

### DynamoDB Table for State Locking
- **Table Name:** `terraform-state-lock`
- **Region:** `us-east-1`
- **Billing Mode:** Pay-per-request
- **Purpose:** Prevents concurrent Terraform operations

---

## Configuration Example

The backend in `terraform/backend.tf` should look like:

```hcl
terraform {
  backend "s3" {
    bucket         = "YOUR-UNIQUE-BUCKET-NAME"  # Your actual bucket
    key            = "ec2-k8s/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

---

## Using the Backend

### Initializing for the First Time

```bash
cd terraform/
terraform init
```

### Migrating Existing Local State

If you have local state files:

```bash
cd terraform/
terraform init -migrate-state
```

Terraform will prompt:
```
Do you want to copy existing state to the new backend? (yes/no)
```

Type `yes` to migrate.

### Working with Remote State

After initialization, Terraform operations work normally:

```bash
# Plan changes
terraform plan

# Apply changes
terraform apply

# View current state
terraform show
```

The state is automatically:
- Stored in S3 after each operation
- Locked during operations via DynamoDB
- Versioned (previous versions can be restored)

---

## Cost Estimates

### S3 Storage
- **First 50 TB/month:** $0.023 per GB
- **Typical state file:** ~100 KB - 10 MB
- **Monthly cost:** < $0.01

### DynamoDB (Pay-per-request)
- **Reads:** $0.25 per million requests
- **Writes:** $1.25 per million requests
- **Typical usage:** 10-100 requests/day
- **Monthly cost:** < $0.05

### Total Monthly Cost
**Estimated:** < $0.15/month

---

## Security Best Practices

### Bucket Permissions
- ✅ Enable versioning (recover from accidents)
- ✅ Enable encryption at rest (AES-256)
- ✅ Use IAM policies to restrict access
- ✅ Consider enabling MFA delete

### State File Security
- **Never commit** `.tfstate` files to version control
- **Limit access** to S3 bucket (use IAM policies)
- **Enable encryption** for state files
- **Review state contents** for sensitive data

### Recommended IAM Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetBucketVersioning"
      ],
      "Resource": "arn:aws:s3:::YOUR-UNIQUE-BUCKET-NAME"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::YOUR-UNIQUE-BUCKET-NAME/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:DescribeTable",
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:*:*:table/terraform-state-lock"
    }
  ]
}
```

---

## Troubleshooting

### Error: "Failed to get existing workspaces"

**Cause:** S3 bucket doesn't exist or wrong name/region

**Solution:**
```bash
# Verify bucket exists
aws s3 ls s3://YOUR-UNIQUE-BUCKET-NAME

# Check region
aws s3api get-bucket-location --bucket YOUR-UNIQUE-BUCKET-NAME
```

### Error: "Error locking state"

**Cause:** DynamoDB table doesn't exist or wrong permissions

**Solution:**
```bash
# Verify table exists
aws dynamodb describe-table --table-name terraform-state-lock

# Check table status (should be ACTIVE)
aws dynamodb describe-table --table-name terraform-state-lock \
  --query 'Table.TableStatus'
```

### Error: "Resource already exists"

**Cause:** Trying to create bucket/table that already exists

**Solution:** Use existing resources or choose different names

### State Lock Stuck

If a lock gets stuck (rare):

```bash
# Force unlock (use with caution!)
terraform force-unlock LOCK_ID
```

Get `LOCK_ID` from the error message.

---

## Additional Resources

- [Terraform S3 Backend Documentation](https://www.terraform.io/docs/backends/types/s3.html)
- [AWS S3 Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/best-practices.html)
- [DynamoDB On-Demand Pricing](https://aws.amazon.com/dynamodb/pricing/on-demand/)

---

## Summary

✅ **Created:** S3 bucket for state storage  
✅ **Created:** DynamoDB table for state locking  
✅ **Configured:** `terraform/backend.tf`  
✅ **Benefits:** Team collaboration, versioning, locking  
✅ **Cost:** < $0.15/month

**Next:** Run `terraform init` to start using remote state!
