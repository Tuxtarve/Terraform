# 1. VPC 생성 (모든 자원이 담길 큰 울타리)
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr  # 보통 "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "${var.project_name}-vpc" }
}

# 2. 인터넷 게이트웨이 (VPC가 외부 인터넷과 통신하는 유일한 통로)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.project_name}-igw" }
}

# 3. 퍼블릭 서브넷 (Web 서버, Load Balancer, NAT Instance용)
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index] # 예: "10.0.1.0/24", "10.0.2.0/24"
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true # 여기에 뜨는 인스턴스는 공인 IP를 가짐

  tags = {
    Name                     = "${var.project_name}-public-${count.index + 1}"
    "kubernetes.io/role/elb" = "1" # EKS가 로드밸런서를 만들 때 필요함
  }
}

# 4. 프라이빗 서브넷 (WAS, EKS Node, DB용)
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index] # 예: "10.0.10.0/24", "10.0.11.0/24"
  availability_zone = var.azs[count.index]

  tags = {
    Name                              = "${var.project_name}-private-${count.index + 1}"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# 5. NAT 인스턴스 전용 보안 그룹 (내부 통신 허용)
resource "aws_security_group" "nat_sg" {
  name   = "${var.project_name}-nat-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr] # VPC 내부 트래픽만 받음
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # 외부로는 어디든 나감
  }
}

# 1. 최신 Ubuntu 22.04 이미지를 자동으로 찾아오는 '검색기' 추가
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical(Ubuntu 제작사) 공식 ID
}

# 2. NAT 인스턴스 생성 (수정된 버전)
resource "aws_instance" "nat" {
  # 직접 ID를 적지 않고 위에서 찾은 ID를 자동으로 사용합니다.
  ami           = data.aws_ami.ubuntu.id 
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public[0].id
  
  # 보안 그룹 설정 (기존 코드 변수명 확인 필요)
  vpc_security_group_ids = [aws_security_group.nat_sg.id]
  
  # NAT 핵심 설정
  source_dest_check = false 

  user_data = <<-EOF
              #!/bin/bash
              echo 1 > /proc/sys/net/ipv4/ip_forward
              iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
              EOF

  tags = { 
    Name = "${var.project_name}-nat-instance" 
  }
}

# 7. 퍼블릭 라우팅 테이블 (0.0.0.0/0 -> 인터넷 게이트웨이)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.project_name}-public-rt" }
}

# 8. 프라이빗 라우팅 테이블 (0.0.0.0/0 -> NAT 인스턴스)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_instance.nat.primary_network_interface_id
  }
  tags = { Name = "${var.project_name}-private-rt" }
}

# 9. 서브넷과 라우팅 테이블 연결 (Association)
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt.id
}
