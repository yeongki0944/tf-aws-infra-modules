# 보안 그룹용 네이밍 호출 (for_each 사용)
module "naming_sg" {
  source   = "../../modules/naming"
  for_each = var.security_groups

  customer      = var.customer
  project       = var.project
  environment   = var.environment
  app_name      = var.app_name
  resource_type = "security_group"
  name          = each.key
}

module "generic_sg" {
  source   = "terraform-aws-modules/security-group/aws"
  version  = "5.3.0"
  for_each = var.security_groups

  name        = module.naming_sg[each.key].result
  description = each.value.description
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = each.value.ingress_rules
  egress_with_cidr_blocks  = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = "0.0.0.0/0" }]

  tags = module.naming_sg[each.key].tags
}