# 1. EKS 클러스터 이름 (기존에 있던 것)
output "eks_cluster_name" {
  value = aws_eks_cluster.main.name
}

# 2. [추가] EKS 클러스터 엔드포인트 (Helm Provider 연결용)
output "eks_cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

# 3. [추가] EKS 클러스터 CA 데이터 (Helm Provider 인증용)
output "eks_cluster_ca" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}

# 4. ECR 주소 (기존에 있던 것)
output "ecr_repository_url" {
  value = aws_ecr_repository.app_repo.repository_url
}
