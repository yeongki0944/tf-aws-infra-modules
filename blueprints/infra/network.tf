# VPC 네이밍 호출
module "naming_vpc" {
  source = "../../modules/naming"
  customer      = var.customer
  project       = var.project
  environment   = var.environment
  app_name      = var.app_name
  resource_type = "virtual_private_cloud"
  name          = "main"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.16.0"

  name = module.naming_vpc.result
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 8, i)]
  public_subnets  = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 8, i + var.az_count)]

  enable_nat_gateway = true
  single_nat_gateway = var.single_nat_gateway

  tags = module.naming_vpc.tags

  # EKS 및 로드밸런서 연동을 위한 필수 태그
  public_subnet_tags = { "kubernetes.io/role/elb" = 1 }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "karpenter.sh/discovery"          = "${module.naming_vpc.prefix}-cluster"
  }
}