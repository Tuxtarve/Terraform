# 1. Helm Provider 설정 (모듈 내부에 명시적으로 정의)
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
  }
}

# 2. Prometheus & Grafana 설치
resource "helm_release" "prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  create_namespace = true

  # Grafana 관리자 비번
  set {
    name  = "grafana.adminPassword"
    value = "soldesk1."
  }

  # 서비스 타입을 LoadBalancer로 변경하여 외부 접속 허용
  set {
    name  = "grafana.service.type"
    value = "LoadBalancer"
  }

  # 에러 났던 cluster_name 변수 활용
  set {
    name  = "global.clusterName"
    value = var.cluster_name
  }
}
