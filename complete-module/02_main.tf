# 테라폼 설정 및 S3 Backend (상태 파일 원격 저장)
terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket         = "soldesk-1109"       # 본인이 생성한 S3 버킷 이름으로 수정!
    key            = "terraform/state.tfstate" # 저장 경로
    region         = "ap-northeast-2"          # 서울 리전
    encrypt        = true                      # 암호화 활성화
  }

required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # [추가] 헬름 프로바이더 선언
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    # [추가] 쿠버네티스 프로바이더 선언
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

# 0. AWS 프로바이더 설정
provider "aws" {
  region = "ap-northeast-2" # 서울 리전 고정
}

# 0-1. Kubernetes Provider 설정 (EKS 접속용)
provider "kubernetes" {
  host                   = module.compute.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.compute.eks_cluster_ca)
  
  # AWS CLI를 통해 실시간으로 인증 토큰을 가져옵니다.
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.compute.eks_cluster_name]
    command     = "aws"
  }
}

# 0-2. Helm Provider 설정 (Prometheus/Grafana 설치용)
provider "helm" {
  kubernetes {
    host                   = module.compute.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.compute.eks_cluster_ca)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.compute.eks_cluster_name]
      command     = "aws"
    }
  }
}
# 1. 네트워크 모듈 호출 (VPC, Subnet, NAT Instance 등)
module "network" {
  source          = "./modules/00_network"
  project_name    = var.project_name
  vpc_cidr        = var.vpc_cidr

  # 아래 4개 항목이 에러에서 요구한 필수값들입니다.
  region          = var.region # "ap-northeast-2" 직접 입력 대신 변수 사용
  azs             = ["ap-northeast-2a", "ap-northeast-2c"]      # 사용할 가용 영역
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]              # 외부 접속용 서브넷
  private_subnets = ["10.0.10.0/24", "10.0.11.0/24"]            # DB/EKS용 내부 서브넷
}

# 2. 보안 그룹 모듈 호출 (WAS_SG, DB_SG 등 관리)
module "security" {
  source          = "./modules/01_security"
  project_name    = var.project_name
  
  # 네트워크 모듈이 만든 vpc_id와 vpc_cidr 값을 그대로 전달합니다.
  public_vpc_id   = module.network.vpc_id     # 네트워크 모듈에서 만든 VPC ID
  private_vpc_id  = module.network.vpc_id     # 동일한 VPC이므로 같은 값 전달
  public_vpc_cidr = var.vpc_cidr              # 루트 변수에서 가져온 CIDR
}

# 3. 데이터베이스 모듈 호출 (RDS 구축)
module "database" {
  source             = "./modules/03_database"
  project_name       = var.project_name
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  db_sg_id           = module.security.db_sg_id # 보안그룹 ID 전달 필요시
}

# 4. EKS/Compute 모듈 (비용 발생 방지를 위해 주석 처리 유지)
# 실습 필요 시에만 아래 주석을 해제하세요.
 module "compute" {
   source       = "./modules/02_compute"
   project_name = var.project_name
   vpc_id       = module.network.vpc_id
   subnet_ids   = module.network.private_subnet_ids
   instance_type = var.instance_type
 }

# 5. EKS 정보 참조조
module "monitoring" {
  source       = "./modules/05_monitoring"
  # 모니터링을 설치하려면 EKS 정보가 필요할 수 있으니 참조를 걸어둡니다.
  cluster_name = module.compute.eks_cluster_name 
}

# 6. cache(redis) 추가
module "cache" {
  source = "./modules/06_cache"
}

# 7. edge 추가
module "edge" {
  source = "./modules/07_edge"
}
