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

# 4. 인터넷 게이트웨이 (VPC의 대문)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-igw" }
}

# 5. 퍼블릭 라우팅 테이블 (인터넷으로 가는 길)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0" # 모든 트래픽을 IGW로 보냄
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "${var.project_name}-public-rt" }
}

# 6. 퍼블릭 서브넷과 라우팅 테이블 연결 (Association)
resource "aws_route_table_association" "public_assoc" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# 7. NAT Gateway용 고정 IP (EIP)
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "${var.project_name}-nat-eip" }
}

# 8. NAT Gateway 생성 (퍼블릭 서브넷 중 하나에 배치)
resource "aws_internet_gateway" "igw" { # (기존 코드 참고용)
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # 첫 번째 퍼블릭 서브넷에 위치
  tags          = { Name = "${var.project_name}-nat" }

  depends_on = [aws_internet_gateway.igw] # IGW가 있어야 생성 가능
}

# 9. 프라이빗 라우팅 테이블 (밖으로 나갈 때 NAT를 거치도록 설정)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = { Name = "${var.project_name}-private-rt" }
}

# 10. 프라이빗 서브넷과 라우팅 테이블 연결
resource "aws_route_table_association" "private_assoc" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}
