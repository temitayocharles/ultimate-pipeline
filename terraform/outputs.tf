output "jenkins_k8s_master_public_ip" {
  description = "Public IP of Jenkins and K8s Master server"
  value       = aws_instance.jenkins_k8s_master.public_ip
}

output "jenkins_k8s_master_private_ip" {
  description = "Private IP of Jenkins and K8s Master server"
  value       = aws_instance.jenkins_k8s_master.private_ip
}

output "k8s_worker_1_public_ip" {
  description = "Public IP of K8s Worker 1"
  value       = aws_instance.k8s_worker_1.public_ip
}

output "k8s_worker_1_private_ip" {
  description = "Private IP of K8s Worker 1"
  value       = aws_instance.k8s_worker_1.private_ip
}

output "k8s_worker_2_public_ip" {
  description = "Public IP of K8s Worker 2"
  value       = var.feature_flags.enable_worker_2 ? aws_instance.k8s_worker_2[0].public_ip : "Not created"
}

output "k8s_worker_2_private_ip" {
  description = "Private IP of K8s Worker 2"
  value       = var.feature_flags.enable_worker_2 ? aws_instance.k8s_worker_2[0].private_ip : "Not created"
}

output "nexus_sonarqube_public_ip" {
  description = "Public IP of Nexus and SonarQube server"
  value       = var.feature_flags.enable_tools_instance ? aws_instance.nexus_sonarqube[0].public_ip : "Not created"
}

output "nexus_sonarqube_private_ip" {
  description = "Private IP of Nexus and SonarQube server"
  value       = var.feature_flags.enable_tools_instance ? aws_instance.nexus_sonarqube[0].private_ip : "Not created"
}

output "monitoring_public_ip" {
  description = "Public IP of Monitoring server"
  value       = var.feature_flags.enable_monitoring_instance ? aws_instance.monitoring[0].public_ip : "Not created"
}

output "monitoring_private_ip" {
  description = "Private IP of Monitoring server"
  value       = var.feature_flags.enable_monitoring_instance ? aws_instance.monitoring[0].private_ip : "Not created"
}

output "jenkins_url" {
  description = "Jenkins URL"
  value       = "http://${aws_instance.jenkins_k8s_master.public_ip}:8080"
}

output "nexus_url" {
  description = "Nexus URL"
  value       = var.feature_flags.enable_tools_instance ? "http://${aws_instance.nexus_sonarqube[0].public_ip}:8081" : "Not created"
}

output "sonarqube_url" {
  description = "SonarQube URL"
  value       = var.feature_flags.enable_tools_instance ? "http://${aws_instance.nexus_sonarqube[0].public_ip}:9000" : "Not created"
}

output "grafana_url" {
  description = "Grafana URL"
  value       = var.feature_flags.enable_monitoring_instance ? "http://${aws_instance.monitoring[0].public_ip}:3000" : "Not created"
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = var.feature_flags.enable_monitoring_instance ? "http://${aws_instance.monitoring[0].public_ip}:9090" : "Not created"
}

output "ssh_commands" {
  description = "SSH commands to connect to instances"
  value = {
    jenkins_k8s_master = "ssh -i ${var.ssh_config.key_name}.pem ubuntu@${aws_instance.jenkins_k8s_master.public_ip}"
    k8s_worker_1       = "ssh -i ${var.ssh_config.key_name}.pem ubuntu@${aws_instance.k8s_worker_1.public_ip}"
    k8s_worker_2       = var.feature_flags.enable_worker_2 ? "ssh -i ${var.ssh_config.key_name}.pem ubuntu@${aws_instance.k8s_worker_2[0].public_ip}" : "Not created"
    nexus_sonarqube    = var.feature_flags.enable_tools_instance ? "ssh -i ${var.ssh_config.key_name}.pem ubuntu@${aws_instance.nexus_sonarqube[0].public_ip}" : "Not created"
    monitoring         = var.feature_flags.enable_monitoring_instance ? "ssh -i ${var.ssh_config.key_name}.pem ubuntu@${aws_instance.monitoring[0].public_ip}" : "Not created"
  }
}

# Service Discovery Outputs
output "service_discovery_namespace" {
  description = "AWS Cloud Map namespace for service discovery"
  value       = aws_service_discovery_private_dns_namespace.cicd.name
}

output "service_discovery_dns_endpoints" {
  description = "DNS endpoints for service discovery (accessible from within VPC)"
  value = {
    jenkins_k8s_master = "jenkins-k8s-master.${aws_service_discovery_private_dns_namespace.cicd.name}"
    k8s_worker_1       = "k8s-worker-1.${aws_service_discovery_private_dns_namespace.cicd.name}"
    k8s_worker_2       = var.feature_flags.enable_worker_2 ? "k8s-worker-2.${aws_service_discovery_private_dns_namespace.cicd.name}" : "Not created"
    tools              = var.feature_flags.enable_tools_instance ? "tools.${aws_service_discovery_private_dns_namespace.cicd.name}" : "Not created"
    monitoring         = var.feature_flags.enable_monitoring_instance ? "monitoring.${aws_service_discovery_private_dns_namespace.cicd.name}" : "Not created"
  }
}

# OIDC Outputs
output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions (use in GitHub workflows)"
  value       = var.oidc_config.enable_github_oidc ? aws_iam_role.github_actions[0].arn : "OIDC not enabled"
}

output "github_actions_setup" {
  description = "Instructions for setting up GitHub Actions with OIDC"
  value       = var.oidc_config.enable_github_oidc ? "Add to GitHub workflow: role-to-assume: ${aws_iam_role.github_actions[0].arn}, aws-region: ${var.aws_config.region}" : "OIDC not enabled - set oidc_config.enable_github_oidc = true"
}