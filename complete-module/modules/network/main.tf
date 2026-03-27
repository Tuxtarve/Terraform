# 1. VPC 생성
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# 2. 퍼블릭 서브넷 (Web / ALB용)
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.azs[count.index]
  
  # EKS가 이 서브넷을 로드밸런서용으로 인식하게 하는 태그
  tags = {
    Name                        = "${var.project_name}-public-${count.index + 1}"
    "kubernetes.io/role/elb"    = "1"
  }
}

# 3. 프라이빗 서브넷 (App / EKS Node용)
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name                               = "${var.project_name}-private-${count.index + 1}"
    "kubernetes.io/role/internal-elb"  = "1"
  }
}
