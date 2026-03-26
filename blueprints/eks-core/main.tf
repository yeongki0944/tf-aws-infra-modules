# =============================================================
# EKS Cluster — 공식 모듈 (terraform-aws-eks)
# 클러스터만 생성. Node Group, Add-on은 별도 레이어.
# =============================================================

module "eks" {
  source = "${var.vendor_module_path}/terraform-aws-eks-v20.31.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # VPC — Datasource에서 조회
  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnet_ids

  # Control Plane 접근
  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = var.cluster_access_cidrs

  # Terraform 실행자에게 admin 권한
  enable_cluster_creator_admin_permissions = true

  # Add-on → eks-addon 레이어에서 관리
  # Node Group → eks-node 레이어에서 관리

  # Karpenter가 노드 프로비저닝 시 사용할 SG 태그
  node_security_group_tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }

  tags = local.common_tags
}
