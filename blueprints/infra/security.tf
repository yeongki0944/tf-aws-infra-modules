# =============================================================
# Security Groups (General Pattern)
# =============================================================

module "generic_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  for_each = var.security_groups

  # ★ 조회 키: cluster_name 기반
  name        = "${var.cluster_name}-${each.key}-sg"
  description = each.value.description
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = each.value.ingress_rules
  egress_with_cidr_blocks  = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = "0.0.0.0/0" }]

  # ★ MSP 태그
  tags = local.common_tags
}