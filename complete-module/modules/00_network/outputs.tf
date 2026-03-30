# 1. 다른 모든 모듈의 기반이 되는 VPC ID
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

# 2. Web/ALB 등을 배치할 퍼블릭 서브넷 ID 목록
output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

# 3. EKS 노드, WAS 등을 배치할 프라이빗 서브넷 ID 목록
output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

# 4. NAT 인스턴스의 프라이빗 IP (트러블슈팅이나 모니터링용)
output "nat_instance_private_ip" {
  value = aws_instance.nat.private_ip
}

# 5. VPC CIDR 블록 (보안 그룹 설정 시 유용함)
output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
}
