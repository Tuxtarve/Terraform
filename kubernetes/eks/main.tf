# 1. EKS 클러스터가 사용할 신분증(Role) 생성
resource "aws_iam_role" "eks_cluster_role" {
  name = "Soldesk_EKS_Cluster_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

# 2. 클러스터 역할에 필수 정책 연결
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# 3. 워커 노드가 사용할 신분증(Role) 생성
resource "aws_iam_role" "node_role" {
  name = "Soldesk_EKS_Node_Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# 4. 워커 노드에 필요한 3가지 필수 정책 연결
resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_role.name
}
# 5. EKS 클러스터 본체 정의
resource "aws_eks_cluster" "my_eks" {
  name     = "Soldesk_EKS_Cluster" # 제안서 명명 규칙 준수
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    # 제안서의 WAS_Pri_SN 같은 프라이빗 서브넷 ID들을 변수로 받아 연결합니다.
    subnet_ids = var.private_subnet_ids 
  }

  # 권한 설정(Role Attachment)이 먼저 완료된 후 클러스터가 생성되도록 순서를 보장합니다.
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# 6. EKS 노드 그룹 정의 (실제 컨테이너가 돌아가는 서버 세트)
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.my_eks.name
  node_group_name = "Soldesk_Node_Group"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 1
  }

  # 인스턴스 타입 설정 (t3.medium은 테스트 및 소규모 프로젝트에 적합)
  instance_types = ["t3.small"]

  # 노드에 필요한 권한들이 모두 연결된 후 생성을 시작합니다.
  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  ]
}