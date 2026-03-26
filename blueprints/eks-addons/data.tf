# =============================================================
# 1. Naming Replication — 인프라 생성 시 사용한 이름 규칙 재현
# =============================================================

# VPC 네이밍 재현 (infra 레이어와 동일 로직)
module "naming_vpc" {
  source        = "../../modules/naming"
  customer      = var.customer
  project       = var.project
  environment   = var.environment
  app_name      = var.app_name
  resource_type = "virtual_private_cloud"
  name          = "eks"
}

module "naming_cluster" {
  source        = "../../modules/naming"
  customer      = var.customer
  project       = var.project
  environment   = var.environment
  app_name      = var.app_name
  resource_type = "eks_cluster" # 네이밍 모듈에 정의된 타입
  name          = "cluster"
}

# Node IAM Role 네이밍 재현
module "naming_node_role" {
  source        = "../../modules/naming"
  customer      = var.customer
  project       = var.project
  environment   = var.environment
  app_name      = var.app_name
  resource_type = "iam_role"
  name          = "node"
}

# =============================================================
# 2. Data Sources — 계산된 네이밍 결과를 사용하여 조회
# =============================================================

data "aws_caller_identity" "current" {}

# EKS Cluster (배포 레이어에서 전달받은 이름 사용)
data "aws_eks_cluster" "this" {
  name = module.naming_cluster.result
}

# VPC (네이밍 모듈의 결과값으로 필터링)
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [module.naming_vpc.result] # "mzc-edu-dev-eks-vpc" 형태
  }
}

# Node IAM Role (네이밍 모듈의 결과값 사용)
data "aws_iam_role" "node" {
  name = module.naming_node_role.result # "mzc-edu-dev-eks-node-role" 형태
}

# Route53 Zone
data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}

# S3 Buckets (General Pattern: Map 순회 조회)
data "aws_s3_bucket" "this" {
  for_each = var.s3_bucket_names
  bucket   = each.value
}

# =============================================================
# 3. Locals — 조회된 데이터를 변수화
# =============================================================

locals {
  account_id = data.aws_caller_identity.current.account_id

  # EKS 정보
  cluster_name      = data.aws_eks_cluster.this.name
  cluster_endpoint  = data.aws_eks_cluster.this.endpoint
  cluster_ca        = data.aws_eks_cluster.this.certificate_authority[0].data
  cluster_version   = data.aws_eks_cluster.this.version
  oidc_provider_arn = "arn:aws:iam::${local.account_id}:oidc-provider/${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}"
  vpc_id            = data.aws_vpc.this.id

  # Node 정보
  node_role_arn = data.aws_iam_role.node.arn

  # DNS 정보
  zone_id     = data.aws_route53_zone.this.zone_id
  domain_name = data.aws_route53_zone.this.name

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}