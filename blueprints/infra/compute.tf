module "compute_key" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "2.0.3"

  for_each = var.compute_instances

  key_name           = "${var.ec2_names[each.key]}-key"
  create_private_key = true
  tags               = var.common_tags
}

resource "aws_instance" "this" {
  for_each = var.compute_instances

  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = each.value.instance_type
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [module.generic_sg[each.key].security_group_id]
  associate_public_ip_address = true
  key_name                    = module.compute_key[each.key].key_pair_name

  tags = merge(var.common_tags, {
    Name = var.ec2_names[each.key]
  })
}