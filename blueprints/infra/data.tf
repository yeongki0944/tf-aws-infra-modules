# =============================================================
# Data Sources — AWS API 직접 조회
# =============================================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# DNS — Route53 Zone
data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}

# AZ 조회
data "aws_availability_zones" "available" {
  state = "available"
}

# Bastion AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# =============================================================
# Locals
# =============================================================
locals {
  azs        = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  zone_id    = data.aws_route53_zone.this.zone_id

  # MSP 태그 — naming 모듈 없이 직접 생성
  common_tags = {
    "msp:customer"    = var.customer
    "msp:project"     = var.project
    "msp:environment" = var.environment
    "msp:managed-by"  = "terraform"
    "msp:app-name"    = var.app_name
  }
}