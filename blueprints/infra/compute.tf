module "naming_compute" {
  source   = "../../modules/naming"
  for_each = toset(["bastion"]) 

  customer      = var.customer
  project       = var.project
  environment   = var.environment
  app_name      = var.app_name
  resource_type = "ec2_instance"
  name          = each.key
}

module "compute_key" {
  source             = "terraform-aws-modules/key-pair/aws"
  version            = "2.0.3"
  for_each           = toset(["bastion"])
  
  key_name           = "${module.naming_compute[each.key].result}-key"
  create_private_key = true
}

resource "aws_instance" "this" {
  for_each = toset(["bastion"])

  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.bastion_instance_type
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [module.generic_sg[each.key].security_group_id]
  associate_public_ip_address = true
  key_name                    = module.compute_key[each.key].key_pair_name

  tags = module.naming_compute[each.key].tags_with_name
}