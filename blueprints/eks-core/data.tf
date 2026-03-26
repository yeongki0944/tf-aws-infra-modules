# 1. VPC 이름을 찾기 위한 네이밍 호출 (infra의 VPC 설정과 동일해야 함)
module "naming_vpc" {
  source = "../../modules/naming"

  customer      = var.customer
  project       = var.project
  environment   = var.environment
  app_name      = var.app_name
  resource_type = "virtual_private_cloud"
  name          = "eks" 
}

# 2. EKS 클러스터 이름을 결정하기 위한 네이밍 호출
module "naming_eks" {
  source = "../../modules/naming"

  customer      = var.customer
  project       = var.project
  environment   = var.environment
  app_name      = var.app_name
  resource_type = "eks_cluster"
  name          = "cluster"
}

# 3. 데이터 소스 조회
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [module.naming_vpc.result]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  filter {
    name   = "tag:kubernetes.io/role/internal-elb"
    values = ["1"]
  }
}

locals {
  vpc_id             = data.aws_vpc.this.id
  private_subnet_ids = data.aws_subnets.private.ids
  common_tags        = module.naming_eks.tags
}