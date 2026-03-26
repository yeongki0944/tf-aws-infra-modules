# 1. 네이밍 모듈: 클러스터 및 VPC 조회를 위한 이름 생성
module "naming_eks" {
  source = "../../modules/naming"

  customer      = var.customer
  project       = var.project
  environment   = var.environment
  app_name      = var.app_name
  resource_type = "eks_cluster"
  name          = "cluster"
}

module "naming_vpc" {
  source = "../../modules/naming"

  customer      = var.customer
  project       = var.project
  environment   = var.environment
  app_name      = var.app_name
  resource_type = "virtual_private_cloud"
  name          = "eks"
}

# 2. 실제 리소스 조회
data "aws_eks_cluster" "this" {
  name = module.naming_eks.result
}

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

# 3. 공통 변수 정리
locals {
  cluster_name       = data.aws_eks_cluster.this.name
  cluster_version    = data.aws_eks_cluster.this.version
  vpc_id             = data.aws_vpc.this.id
  private_subnet_ids = data.aws_subnets.private.ids
  common_tags        = module.naming_eks.tags
}