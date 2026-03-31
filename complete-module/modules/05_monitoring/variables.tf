variable "cluster_name" {
  description = "EKS 클러스터의 이름입니다."
  type        = string
}

# (선택 사항) 만약 main.tf에서 vpc_id 등 다른 값도 쓰고 있다면 여기서 함께 선언해야 합니다.
