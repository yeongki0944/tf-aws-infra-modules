# =============================================================
# Data Sources — 모든 의존성을 AWS API로 직접 조회
# =============================================================

data "aws_caller_identity" "current" {}

# EKS Cluster
data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

# VPC
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${var.cluster_name}-vpc"]
  }
}

# Node IAM Role
data "aws_iam_role" "node" {
  name = "${var.cluster_name}-node-role"
}

# Route53 Zone
data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}

data "aws_s3_bucket" "this" {
  for_each = var.s3_bucket_names
  bucket   = each.value
}
locals {
  account_id = data.aws_caller_identity.current.account_id

  # EKS
  cluster_name      = data.aws_eks_cluster.this.name
  cluster_endpoint  = data.aws_eks_cluster.this.endpoint
  cluster_ca        = data.aws_eks_cluster.this.certificate_authority[0].data
  cluster_version   = data.aws_eks_cluster.this.version
  oidc_provider_arn = "arn:aws:iam::${local.account_id}:oidc-provider/${replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")}"
  vpc_id            = data.aws_vpc.this.id

  # Node
  node_role_arn = data.aws_iam_role.node.arn

  # DNS
  zone_id     = data.aws_route53_zone.this.zone_id
  domain_name = data.aws_route53_zone.this.name

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
