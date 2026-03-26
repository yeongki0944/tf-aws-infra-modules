module "generic_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  for_each = var.security_groups

  name        = var.sg_names[each.key]
  description = each.value.description
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = each.value.ingress_rules
  egress_with_cidr_blocks  = [{ from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = "0.0.0.0/0" }]

  tags = var.common_tags
}