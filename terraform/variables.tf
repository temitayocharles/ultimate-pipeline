variable "aws_config" {
  description = "AWS configuration settings"
  type = object({
    region = string
  })
}

variable "ami_config" {
  description = "AMI configuration"
  type = object({
    id = string
  })
}

variable "ssh_config" {
  description = "SSH configuration"
  type = object({
    key_name     = string
    allowed_cidr = list(string)
  })
}

variable "instance_types" {
  description = "EC2 instance type configuration"
  type = object({
    master     = string
    worker     = string
    monitoring = string
  })
}

variable "project_config" {
  description = "Project tagging and naming configuration"
  type = object({
    name        = string
    environment = string
  })
}

variable "feature_flags" {
  description = "Feature toggles for optional infrastructure components"
  type = object({
    enable_monitoring_instance = bool
    enable_tools_instance      = bool
    enable_worker_2            = bool
  })
}