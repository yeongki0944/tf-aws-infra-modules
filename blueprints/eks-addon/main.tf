# =============================================================
# 1. Custom IRSA (IAM Roles for Service Accounts) 동적 생성
# =============================================================

module "custom_irsa" {
  # ✅ 공식 레지스트리로 변경 완료
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39.0" # 최신 5.x 버전대 사용
  
  for_each = var.custom_irsas

  role_name = "${local.cluster_name}-${each.key}"

  oidc_providers = {
    main = {
      provider_arn               = local.oidc_provider_arn
      namespace_service_accounts = ["${each.value.namespace}:${each.value.service_account}"]
    }
  }

  tags = local.common_tags
}

resource "aws_iam_role_policy" "custom_irsa_inline" {
  for_each = { for k, v in var.custom_irsas : k => v if v.inline_policy_json != null }

  name   = "${local.cluster_name}-${each.key}-policy"
  role   = module.custom_irsa[each.key].iam_role_name
  policy = each.value.inline_policy_json
}

locals {
  irsa_managed_policies = flatten([
    for irsa_key, irsa_val in var.custom_irsas : [
      for policy_arn in try(irsa_val.managed_policy_arns, []) : {
        irsa_key   = irsa_key
        policy_arn = policy_arn
      }
    ]
  ])
}

resource "aws_iam_role_policy_attachment" "custom_irsa_managed" {
  for_each = { for item in local.irsa_managed_policies : "${item.irsa_key}-${item.policy_arn}" => item }

  role       = module.custom_irsa[each.value.irsa_key].iam_role_name
  policy_arn = each.value.policy_arn
}

# =============================================================
# 2. EKS Blueprints Addons
# =============================================================

module "eks_blueprints_addons" {
  # ✅ AWS 공식 EKS Blueprints Addons 레지스트리로 변경 완료
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.19.0" # 기존에 사용하시던 1.19.0 버전 유지

  cluster_name      = local.cluster_name
  cluster_endpoint  = local.cluster_endpoint
  cluster_version   = local.cluster_version
  oidc_provider_arn = local.oidc_provider_arn

  # ① EKS Managed Add-ons
  eks_addons = {
    coredns                         = { most_recent = true }
    kube-proxy                      = { most_recent = true }
    vpc-cni                         = { most_recent = true }
    
    aws-ebs-csi-driver = { 
      most_recent              = true
      # 외부에서 "ebs_csi"로 주입한 IRSA Role ARN을 자동 매핑
      service_account_role_arn = try(module.custom_irsa["ebs_csi"].iam_role_arn, null)
    }
    
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
# 3. Karpenter 노드 보안 및 권한
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