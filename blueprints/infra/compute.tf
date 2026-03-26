# =============================================================
# Key Pair
# =============================================================

module "compute_key" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "2.0.3"

  for_each = var.compute_instances

  key_name           = "${var.cluster_name}-${each.key}-key"
  create_private_key = true

  tags = local.common_tags
}

# =============================================================
# EC2 Instances (General Pattern)
# =============================================================

resource "aws_instance" "this" {
  for_each = var.compute_instances

  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = each.value.instance_type
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [module.generic_sg[each.key].security_group_id]
  associate_public_ip_address = true
  key_name                    = module.compute_key[each.key].key_pair_name

  # ★ Name 태그: cluster_name 기반 (조회 키)
  # ★ MSP 태그: naming 모듈에서 가져옴
  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-${each.key}"
  })
}