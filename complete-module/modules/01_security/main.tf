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

# 3. DB 보안 그룹 (WAS -> DB / Peering 통로 허용)
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
