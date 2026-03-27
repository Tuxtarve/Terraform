variable "project_name" { default = "my-project" }
variable "vpc_cidr"     { default = "10.0.0.0/16" }
variable "azs"          { default = ["ap-northeast-2a", "ap-northeast-2c"] }
variable "public_subnets"  { default = ["10.0.1.0/24", "10.0.2.0/24"] }
variable "private_subnets" { default = ["10.0.10.0/24", "10.0.11.0/24"] }
