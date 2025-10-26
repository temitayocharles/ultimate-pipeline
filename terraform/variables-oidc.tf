# OIDC Configuration for GitHub Actions
# This allows GitHub Actions to authenticate to AWS without storing credentials

# Add OIDC configuration to variables
variable "oidc_config" {
  description = "OIDC provider configuration for GitHub Actions"
  type = object({
    github_org         = string
    github_repo        = string
    enable_github_oidc = bool
  })
}

# IAM instance profile configuration
variable "iam_config" {
  description = "IAM role configuration for EC2 instances"
  type = object({
    enable_instance_profiles = bool
  })
}
