# =============================================================
# Data Sources — AWS API 직접 조회
# =============================================================

# 1. 현재 실행 중인 AWS 계정 및 리전 정보
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# 2. DNS — Route53 Zone
data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}

# 3. 가용 영역(AZ) 조회
data "aws_availability_zones" "available" { 
  state = "available" 
}

# 4. Bastion AMI (최신 Amazon Linux 2023)
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter { name = "name"; values = ["al2023-ami-*-x86_64"] }
  filter { name = "virtualization-type"; values = ["hvm"] }
}

# Global Naming Module 호출
module "naming_global" {
  source = "../../modules/naming"
  customer      = var.customer
  project       = var.project
  environment   = var.environment
  app_name      = var.app_name
  resource_type = "virtual_private_cloud" # 기본값
  name          = "global"
}

# Local Values — 공통 변수 관리
locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  zone_id     = data.aws_route53_zone.this.zone_id
  domain_name = data.aws_route53_zone.this.name
  common_tags = module.naming_global.tags
}