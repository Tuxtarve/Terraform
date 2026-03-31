# modules/03_database/variables.tf

variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "DB가 위치할 프라이빗 서브넷 ID 리스트"
  type        = list(string)
}

variable "db_sg_id" {
  description = "데이터베이스용 보안 그룹 ID"
  type        = string
}
