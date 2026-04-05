# 1. 테라폼 및 프로바이더 설정
# 테라폼에게 "우리는 헬름(Helm) 도구가 필요해"라고 선언하는 구간이야.
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0" # 2.0.0 이상의 최신 기능을 사용하겠다는 뜻
    }
  }
}

# 헬름 기사님이 어느 쿠버네티스 클러스터에 접속할지 알려줘야 해.
# kops로 만든 환경이라면 보통 ~/.kube/config 파일에 접속 정보가 있어.
provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

# 2. Prometheus & Grafana 설치 (kube-prometheus-stack)
# 헬름 차트(앱 패키지)를 클러스터에 배포하는 리소스야.
resource "helm_release" "prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true

  # ✅ 블록 형태(set { })가 아닌 할당 형태(set = [ { } ])로 변경
  set = [
    {
      name  = "grafana.adminPassword"
      value = "soldesk1."
    },
    {
      name  = "grafana.service.type"
      value = "LoadBalancer"
    },
    {
      name  = "global.clusterName"
      value = var.cluster_name
    }
  ]
}
