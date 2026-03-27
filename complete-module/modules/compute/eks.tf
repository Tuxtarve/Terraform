# 1. EKS 클러스터 정의 (Control Plane)
resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    # 아까 network 모듈에서 만든 서브넷들을 여기에 연결할 거야
    subnet_ids = var.subnet_ids
    endpoint_public_access = true
  }

  # IAM Role 정책이 먼저 완료되어야 클러스터 생성이 가능함
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# 2. EKS 노드 그룹 (프리티어 사양으로 변경)
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 1 # 프리티어니까 1대만 띄워서 테스트하자!
    max_size     = 2
    min_size     = 1
  }

  # 중요: t2.micro는 프리티어 대상이야 (리전에 따라 t3.micro도 가능)
  instance_types = ["t2.micro"] 

  # 디스크 크기도 기본 20GB면 충분해 (프리티어 EBS 한도 30GB 이내)
  disk_size = 20

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_readonly,
  ]
}
