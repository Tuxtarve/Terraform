# 1. AWS 공급자 설정 (어디에 만들지 정의)
provider "aws" {
  region = "ap-northeast-2" # 서울 리전
}

# 2. Public VPC 생성
resource "aws_vpc" "public_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  
  tags = {
    Name = "Public_VPC"
  }
}

# 3. 인터넷 게이트웨이 (외부 인터넷과 연결되는 대문)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.public_vpc.id

  tags = {
    Name = "Public_VPC_IGW"
  }
}

# 4. Public 서브넷 1 (AZ-A)
resource "aws_subnet" "web_pub_sn1" {
  vpc_id            = aws_vpc.public_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true # 공인 IP 자동 할당

  tags = {
    Name = "Public_VPC_Web_Pub_RT_SN1"
  }
}

# 5. Public 서브넷 2 (AZ-C) - 고가용성을 위해 2개 구성
resource "aws_subnet" "web_pub_sn2" {
  vpc_id            = aws_vpc.public_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public_VPC_Web_Pub_RT_SN2"
  }
}

# 6. 라우팅 테이블 (교통 정리판)
resource "aws_route_table" "web_pub_rt" {
  vpc_id = aws_vpc.public_vpc.id

  route {
    cidr_block = "0.0.0.0/0" # 모든 외부 요청은
    gateway_id = aws_internet_gateway.igw.id # 인터넷 게이트웨이로 보냄
  }

  tags = {
    Name = "Public_VPC_Web_Pub_RT"
  }
}

# 7. 라우팅 테이블 - 서브넷 연결 (RT를 SN에 붙여줌)
resource "aws_route_table_association" "rt_assoc_1" {
  subnet_id      = aws_subnet.web_pub_sn1.id
  route_table_id = aws_route_table.web_pub_rt.id
}

resource "aws_route_table_association" "rt_assoc_2" {
  subnet_id      = aws_subnet.web_pub_sn2.id
  route_table_id = aws_route_table.web_pub_rt.id
}

# 8. 보안 그룹 (Security Group - Web 전용 방화벽)
resource "aws_security_group" "web_sg" {
  name        = "Web_SG"
  description = "Allow HTTP, SSH, HTTPS, ICMP"
  vpc_id      = aws_vpc.public_vpc.id

  # 인바운드 규칙 (들어오는 트래픽)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # HTTP 허용
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # SSH 허용 (실무에선 특정 IP만 허용 권장)
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # HTTPS 허용
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"] # Ping 허용
  }

  # 아웃바운드 규칙 (나가는 트래픽 - 모두 허용)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web_SG"
  }
}
