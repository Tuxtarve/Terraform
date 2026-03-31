# ECR 주소: 도커 이미지를 저장할 저장소 주소입니다.
output "ecr_repository_url" {
  value = module.compute.ecr_repository_url
}

# EKS 클러스터 이름: 나중에 kubectl 설정을 위해 필요합니다.
output "eks_cluster_name" {
  value = module.compute.eks_cluster_name
}

# RDS 엔드포인트: 앱이 데이터베이스에 접속할 때 필요합니다.
output "rds_hostname" {
  value = module.database.db_instance_endpoint
}
