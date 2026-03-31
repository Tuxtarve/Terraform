# RDS 인스턴스의 접속 주소(Endpoint)를 밖으로 던져줍니다.
output "db_instance_endpoint" {
  value = aws_db_instance.default.endpoint
}
