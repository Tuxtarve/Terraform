# 1. 네트워크 모듈 호출
module "network" {
  source       = "./modules/network"
  project_name = var.project_name
}

# 2. EKS 클러스터 모듈 호출 (네트워크 정보 전달)
module "compute" {
  source       = "./modules/compute"
  project_name = var.project_name
  vpc_id       = module.network.vpc_id
  subnet_ids   = module.network.private_subnet_ids
}

# 3. 데이터베이스 모듈 호출 (네트워크 정보 전달)
module "database" {
  source             = "./modules/database"
  project_name       = var.project_name
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  app_subnet_cidr    = "10.0.10.0/24" # App이 위치한 프라이빗 대역
}
