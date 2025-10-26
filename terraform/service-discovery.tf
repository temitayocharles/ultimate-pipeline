# Create a private DNS namespace for service discovery
resource "aws_service_discovery_private_dns_namespace" "cicd" {
  name        = "${var.project_config.name}.local"
  description = "Private DNS namespace for CI/CD infrastructure service discovery"
  vpc         = data.aws_vpc.default.id

  tags = {
    Name        = "${var.project_config.name}-service-discovery"
    Project     = var.project_config.name
    Environment = var.project_config.environment
  }
}

# Jenkins & K8s Master Service
resource "aws_service_discovery_service" "jenkins_k8s_master" {
  name = "jenkins-k8s-master"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.cicd.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
  }

  tags = {
    Name        = "${var.project_config.name}-jenkins-k8s-master-discovery"
    Project     = var.project_config.name
    Environment = var.project_config.environment
  }
}

# Register Jenkins/K8s Master instance
resource "aws_service_discovery_instance" "jenkins_k8s_master" {
  instance_id = aws_instance.jenkins_k8s_master.id
  service_id  = aws_service_discovery_service.jenkins_k8s_master.id

  attributes = {
    AWS_INSTANCE_IPV4 = aws_instance.jenkins_k8s_master.private_ip
    AWS_INSTANCE_PORT = "8080"
  }
}

# K8s Worker 1 Service
resource "aws_service_discovery_service" "k8s_worker_1" {
  name = "k8s-worker-1"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.cicd.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
  }

  tags = {
    Name        = "${var.project_config.name}-k8s-worker-1-discovery"
    Project     = var.project_config.name
    Environment = var.project_config.environment
  }
}

resource "aws_service_discovery_instance" "k8s_worker_1" {
  instance_id = aws_instance.k8s_worker_1.id
  service_id  = aws_service_discovery_service.k8s_worker_1.id

  attributes = {
    AWS_INSTANCE_IPV4 = aws_instance.k8s_worker_1.private_ip
  }
}

# K8s Worker 2 Service (conditional)
resource "aws_service_discovery_service" "k8s_worker_2" {
  count = var.feature_flags.enable_worker_2 ? 1 : 0
  name  = "k8s-worker-2"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.cicd.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
  }

  tags = {
    Name        = "${var.project_config.name}-k8s-worker-2-discovery"
    Project     = var.project_config.name
    Environment = var.project_config.environment
  }
}

resource "aws_service_discovery_instance" "k8s_worker_2" {
  count       = var.feature_flags.enable_worker_2 ? 1 : 0
  instance_id = aws_instance.k8s_worker_2[0].id
  service_id  = aws_service_discovery_service.k8s_worker_2[0].id

  attributes = {
    AWS_INSTANCE_IPV4 = aws_instance.k8s_worker_2[0].private_ip
  }
}

# Nexus & SonarQube Service (conditional)
resource "aws_service_discovery_service" "nexus_sonarqube" {
  count = var.feature_flags.enable_tools_instance ? 1 : 0
  name  = "tools"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.cicd.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = {
    Name        = "${var.project_config.name}-tools-discovery"
    Project     = var.project_config.name
    Environment = var.project_config.environment
  }
}
resource "aws_service_discovery_instance" "nexus_sonarqube" {
  count       = var.feature_flags.enable_tools_instance ? 1 : 0
  instance_id = aws_instance.nexus_sonarqube[0].id
  service_id  = aws_service_discovery_service.nexus_sonarqube[0].id

  attributes = {
    AWS_INSTANCE_IPV4 = aws_instance.nexus_sonarqube[0].private_ip
    NEXUS_PORT        = "8081"
    SONARQUBE_PORT    = "9000"
  }
}

# Monitoring Service (conditional)
resource "aws_service_discovery_service" "monitoring" {
  count = var.feature_flags.enable_monitoring_instance ? 1 : 0
  name  = "monitoring"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.cicd.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = {
    Name        = "${var.project_config.name}-monitoring-discovery"
    Project     = var.project_config.name
    Environment = var.project_config.environment
  }
}

resource "aws_service_discovery_instance" "monitoring" {
  count       = var.feature_flags.enable_monitoring_instance ? 1 : 0
  instance_id = aws_instance.monitoring[0].id
  service_id  = aws_service_discovery_service.monitoring[0].id

  attributes = {
    AWS_INSTANCE_IPV4  = aws_instance.monitoring[0].private_ip
    PROMETHEUS_PORT    = "9090"
    GRAFANA_PORT       = "3000"
    NODE_EXPORTER_PORT = "9100"
  }
}
