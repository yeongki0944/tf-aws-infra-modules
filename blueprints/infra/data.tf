data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}

data "aws_availability_zones" "available" {
  state = "available"
}

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
  azs     = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  zone_id = data.aws_route53_zone.this.zone_id
}