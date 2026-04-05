# 1. Web 계층 보안그룹 ID (ALB나 Bastion 등에서 사용)
output "web_sg_id" { 
  value = aws_security_group.web_sg.id 
}

# 2. WAS 계층 보안그룹 ID (김원희, 장예지 파트 - EKS Node Group에서 사용)
output "was_sg_id" { 
  value = aws_security_group.was_sg.id 
}

# 3. DB 계층 보안그룹 ID (지승훈, 이희경 파트 - RDS에서 사용)
output "db_sg_id" { 
  value = aws_security_group.db_sg.id 
}

# 4. Peering ID (라우팅 테이블 업데이트 확인용)
/*
output "peering_id" { 

  value = aws_vpc_peering_connection.db_peering.id
}
*/
