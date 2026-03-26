# =============================================================
# VPC
# =============================================================

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.16.0"

  # ★ 조회 키: cluster_name 기반 (다른 레이어에서 이 이름으로 찾음)
  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 8, i)]
  public_subnets  = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 8, i + var.az_count)]

  enable_nat_gateway = true
  single_nat_gateway = var.single_nat_gateway

  # ★ MSP 태그는 naming 모듈에서 가져옴
  tags = local.common_tags

  # EKS 연동 태그
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "karpenter.sh/discovery"          = var.cluster_name
  }
}