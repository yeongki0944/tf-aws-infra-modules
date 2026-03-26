# =============================================================
# EKS Blueprints Addons
# =============================================================

module "eks_blueprints_addons" {
  source = "${var.vendor_module_path}/terraform-aws-eks-blueprints-addons-v1.19.0"

  cluster_name      = local.cluster_name
  cluster_endpoint  = local.cluster_endpoint
  cluster_version   = local.cluster_version
  oidc_provider_arn = local.oidc_provider_arn

  # ① EKS Managed Add-ons
  eks_addons = {
    coredns                         = { most_recent = true }
    kube-proxy                      = { most_recent = true }
    vpc-cni                         = { most_recent = true }
    aws-ebs-csi-driver              = { most_recent = true, service_account_role_arn = module.ebs_csi_irsa.iam_role_arn }
    amazon-cloudwatch-observability = { most_recent = true }
    external-dns                    = { most_recent = true }
    metrics-server                  = { most_recent = true }
    fluent-bit                      = { most_recent = true }
    kube-state-metrics              = { most_recent = true }
    prometheus-node-exporter        = { most_recent = true }
  }

  # ② Helm — ALB Controller
  enable_aws_load_balancer_controller = true
  aws_load_balancer_controller = {
    set = [
      {
        name  = "vpcId"
        value = local.vpc_id
      }
    ]
  }

  # ③ Helm — Karpenter
  enable_karpenter = true
  karpenter = {
    chart_version = var.karpenter_version
  }
  karpenter_node = {
    iam_role_use_name_prefix = false
    iam_role_name            = "${local.cluster_name}-karpenter-node"
  }

  # ④ Helm — ArgoCD
  enable_argocd = true
  argocd = {
    chart_version = var.argocd_version
    values        = [file("${path.module}/values/argocd-values.yaml")]
  }

  tags = local.common_tags
}

# =============================================================
# Karpenter 노드 보안 및 권한
# =============================================================

resource "aws_eks_access_entry" "karpenter_node" {
  cluster_name  = local.cluster_name
  principal_arn = "arn:aws:iam::${local.account_id}:role/${local.cluster_name}-karpenter-node"
  type          = "EC2_LINUX"

  depends_on = [module.eks_blueprints_addons]
}

resource "aws_iam_role_policy_attachment" "karpenter_node_ebs" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = "${local.cluster_name}-karpenter-node"

  depends_on = [module.eks_blueprints_addons]
}

# =============================================================
# IRSA — EBS CSI Driver
# =============================================================

module "ebs_csi_irsa" {
  source = "${var.vendor_module_path}/terraform-aws-iam-v5.59.0/modules/iam-role-for-service-accounts-eks"

  role_name             = "${local.cluster_name}-ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = local.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.common_tags
}

# =============================================================
# IRSA — Loki (S3 접근)
# =============================================================

module "loki_irsa" {
  source = "${var.vendor_module_path}/terraform-aws-iam-v5.59.0/modules/iam-role-for-service-accounts-eks"

  role_name = "${local.cluster_name}-loki"

  oidc_providers = {
    main = {
      provider_arn               = local.oidc_provider_arn
      namespace_service_accounts = ["loki:loki"]
    }
  }

  tags = local.common_tags
}

resource "aws_iam_role_policy" "loki_s3" {
  name = "${local.cluster_name}-loki-s3"
  role = module.loki_irsa.iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${local.loki_chunks_bucket}",
          "arn:aws:s3:::${local.loki_chunks_bucket}/*",
          "arn:aws:s3:::${local.loki_ruler_bucket}",
          "arn:aws:s3:::${local.loki_ruler_bucket}/*"
        ]
      }
    ]
  })
}

# =============================================================
# IRSA — OpenCost (Pricing API)
# =============================================================

module "opencost_irsa" {
  source = "${var.vendor_module_path}/terraform-aws-iam-v5.59.0/modules/iam-role-for-service-accounts-eks"

  role_name = "${local.cluster_name}-opencost"

  oidc_providers = {
    main = {
      provider_arn               = local.oidc_provider_arn
      namespace_service_accounts = ["monitoring:opencost"]
    }
  }

  tags = local.common_tags
}

resource "aws_iam_role_policy" "opencost" {
  name = "${local.cluster_name}-opencost"
  role = module.opencost_irsa.iam_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "pricing:GetProducts",
          "pricing:DescribeServices",
          "ce:GetCostAndUsage",
          "ce:GetCostForecast"
        ]
        Resource = "*"
      }
    ]
  })
}
