# 추가: RDS가 들어갈 서브넷 그룹 정의
resource "aws_db_subnet_group" "default" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids  # DB는 안전하게 프라이빗 서브넷에!

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "mydb"
  username               = "soldesk"
  password               = "soldesk1."
  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.default.name 
  vpc_security_group_ids = [var.db_sg_id]
  skip_final_snapshot    = true
}
