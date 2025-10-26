# backend.tf - Remote State Configuration
# 
# SETUP INSTRUCTIONS:
# 1. Create an S3 bucket for Terraform state (must be globally unique):
#    aws s3api create-bucket --bucket YOUR-UNIQUE-BUCKET-NAME --region us-east-1
#
# 2. Enable versioning on the bucket:
#    aws s3api put-bucket-versioning --bucket YOUR-UNIQUE-BUCKET-NAME \
#      --versioning-configuration Status=Enabled
#
# 3. Create a DynamoDB table for state locking:
#    aws dynamodb create-table \
#      --table-name terraform-state-lock \
#      --attribute-definitions AttributeName=LockID,AttributeType=S \
#      --key-schema AttributeName=LockID,KeyType=HASH \
#      --billing-mode PAY_PER_REQUEST \
#      --region us-east-1
#
# 4. Uncomment the backend configuration below and update the bucket name
# 5. Run: terraform init -migrate-state
#
# IMPORTANT: 
# - The bucket name must be globally unique across ALL AWS accounts
# - Suggested naming: terraform-state-<your-name>-<random-string>
# - Example: terraform-state-alice-k8s-abc123
# - Share the bucket name and region with your colleagues
#
# FOR LOCAL USE:
# - Copy this file to backend.tf.personal
# - Configure with your actual bucket name in the .personal file
# - The .personal file is gitignored and won't be pushed upstream

# Backend configuration - TEMPLATE VERSION
# Uncomment and configure with your actual S3 bucket and DynamoDB table
terraform {
  # backend "s3" {
  #   bucket         = "YOUR-UNIQUE-BUCKET-NAME-HERE"     # Replace with your bucket name
  #   key            = "ec2-k8s/terraform.tfstate"        # Path within bucket
  #   region         = "us-east-1"                        # Must match bucket region
  #   encrypt        = true                               # Encrypt state file
  #   dynamodb_table = "terraform-state-lock"             # For state locking
  # }
}

# Alternative: Use this for quick local testing (not recommended for team use)
# Just comment out or delete the S3 backend block above and Terraform will use local state
