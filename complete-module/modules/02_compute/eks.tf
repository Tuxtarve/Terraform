# 1. EKS 클러스터 정의 (Control Plane)
resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    # network 모듈에서 전달받은 서브넷 ID들 (보통 Private Subnet 권장)
    subnet_ids = var.subnet_ids
    endpoint_public_access = true
  }

  # IAM Role 정책 연결이 완료된 후 클러스터 생성 시작
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# 2. EKS 노드 그룹 (프리티어 최적화: t3.micro)
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 2 # 비용 절감을 위해 최소 단위 1대 유지
    max_size     = 2
    min_size     = 1
  }

  # [변경 완료] t3.micro는 서울 리전 프리티어 대상이며, t2보다 EKS 구동에 더 안정적입니다.
instance_types = [var.instance_type]
  # EBS 디스크 크기 (프리티어 계정당 총 30GB 제한이므로 20GB면 적당함)
  disk_size = 20

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_readonly,
  ]
}

# 3. ECR 리포지토리 (도커 이미지 저장소)
resource "aws_ecr_repository" "app_repo" {
  name                 = "${var.project_name}-repo"
  image_tag_mutability = "MUTABLE" # 같은 태그(예: latest)로 덮어쓰기 허용

  image_scanning_configuration {
    scan_on_push = true # 이미지 업로드 시 보안 취약점 자동 스캔 (권장)
  }

  force_delete = true # 실습용이므로 리포지토리에 이미지가 있어도 terraform destroy 시 삭제되도록 설정

  tags = {
    Name = "${var.project_name}-ecr"
  }
}
