variable "project_name" {
  type        = string
  description = "Project name inherited from root"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs inherited from root"
}
variable "vpc_id" {
  type        = string
  description = "VPC ID inherited from root"
}
