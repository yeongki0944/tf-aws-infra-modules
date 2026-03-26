# =============================================================
# Data Sources — AWS API 직접 조회
# =============================================================

# EKS Cluster
data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

# VPC
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${var.cluster_name}-vpc"]
  }
}

# IRSA Roles
data "aws_iam_role" "loki" {
  name = "${var.cluster_name}-loki"
}

data "aws_iam_role" "opencost" {
  name = "${var.cluster_name}-opencost"
}

# Loki S3 Buckets
data "aws_s3_bucket" "loki_chunks" {
  bucket = "loki-${var.project}-chunks"
}

data "aws_s3_bucket" "loki_ruler" {
  bucket = "loki-${var.project}-ruler"
}

# Karpenter Node Role
data "aws_iam_role" "karpenter_node" {
  name = "${var.cluster_name}-karpenter-node"
}

locals {
  cluster_name     = data.aws_eks_cluster.this.name
  cluster_endpoint = data.aws_eks_cluster.this.endpoint
  cluster_ca       = data.aws_eks_cluster.this.certificate_authority[0].data

  loki_irsa_arn                = data.aws_iam_role.loki.arn
  opencost_irsa_arn            = data.aws_iam_role.opencost.arn
  loki_chunks_bucket           = data.aws_s3_bucket.loki_chunks.id
  loki_ruler_bucket            = data.aws_s3_bucket.loki_ruler.id
  karpenter_node_iam_role_name = data.aws_iam_role.karpenter_node.name
  vpc_id                       = data.aws_vpc.this.id
}
