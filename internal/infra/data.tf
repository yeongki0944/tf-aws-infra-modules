# =============================================================
# Data Sources — AWS API 직접 조회
# =============================================================

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

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  zone_id     = data.aws_route53_zone.this.zone_id
  domain_name = data.aws_route53_zone.this.name

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
