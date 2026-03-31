# 1. VPC Peering (두 개의 VPC를 물리적으로 연결)
resource "aws_vpc_peering_connection" "db_peering" {
  vpc_id        = var.public_vpc_id   # 00_network에서 만든 Public VPC
  peer_vpc_id   = var.private_vpc_id  # 00_network에서 만든 Private VPC
  auto_accept   = true

  tags = { Name = "${var.project_name}-peering" }
}

# 2. Web 보안 그룹 (외부 인터넷 -> Web/WAS)
resource "aws_security_group" "web_sg" {
  name        = "Web_SG"
  description = "Allow HTTP, HTTPS, SSH, ICMP from Internet"
  vpc_id      = var.public_vpc_id

  # HTTP (80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH (22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 실습용 (보안상 자기 IP 권장)
  }

  # ICMP (Ping 테스트용)
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "Web_SG" }
}

# 3. WAS 보안 그룹 (작업한 김원희, 장예지 님 파트)
resource "aws_security_group" "was_sg" {
  name        = "WAS_SG"
  description = "Allow 8080 from Web_SG"
  vpc_id      = var.public_vpc_id  # WAS가 위치한 VPC ID

  # 인바운드: Web_SG 보안 그룹을 가진 서버로부터의 8080 포트만 허용
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id] # 여기서 Web_SG의 ID를 참조합니다!
  }

  # SSH 접속 (관리용)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  # 아웃바운드: 모든 통신 허용 (DB로 가기 위해 필요)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "WAS_SG" }
}

# 4. DB 보안 그룹 (WAS -> DB / Peering 통로 허용)
resource "aws_security_group" "db_sg" {
  name        = "DB_SG"
  description = "Allow MySQL from Public VPC via Peering"
  vpc_id      = var.private_vpc_id

  # MySQL (3306) - Public VPC의 대역폭 전체를 허용하여 Peering 통신 가능하게 함
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.public_vpc_cidr] 
  }

  # SSH (22) - 관리용
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.public_vpc_cidr]
  }

  # ICMP (Ping)
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.public_vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "DB_SG" }
}
