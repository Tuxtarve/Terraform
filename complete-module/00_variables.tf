variable "region" {
  default = "ap-northeast-2"
}

variable "project_name" {
  default = "yunjihun-project"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

# [추가] EKS 클러스터 이름 변수
# 02_main.tf나 모듈에서 이 이름을 참조하게 됩니다.
variable "cluster_name" {
  default = "yunjihun-eks-cluster"
}

variable "instance_type" {
  description = "EKS node instance type"
  type        = string
}
