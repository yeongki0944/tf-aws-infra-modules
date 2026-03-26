module "naming_iam_role" {
  source = "../../modules/naming"

  customer      = var.customer
  project       = var.project
  environment   = var.environment
  app_name      = var.app_name
  resource_type = "iam_role"  # 결과적으로 "-role-"이 붙음
  name          = "eks-cluster"   # 용도 명시
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31.0"

  cluster_name    = module.naming_eks.result
  cluster_version = var.cluster_version

  iam_role_name            = module.naming_iam_role.result
  iam_role_use_name_prefix = false 

  vpc_id     = local.vpc_id
  subnet_ids = local.private_subnet_ids

  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = var.cluster_access_cidrs

  enable_cluster_creator_admin_permissions = true

  node_security_group_tags = {
    "karpenter.sh/discovery" = module.naming_eks.result
  }

  tags = local.common_tags
}

# =============================================================
# EKS Cluster Admin Access Entries
# =============================================================

resource "aws_eks_access_entry" "admin" {
  for_each      = toset(var.cluster_admin_arns)
  
  # 수정됨: 모듈에서 생성된 클러스터 이름을 참조
  cluster_name  = module.eks.cluster_name
  principal_arn = each.value
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  for_each      = toset(var.cluster_admin_arns)
  
  # 수정됨: 모듈에서 생성된 클러스터 이름을 참조
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:iam::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = each.value

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.admin]
}