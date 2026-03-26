# 1. EC2 네이밍 모듈
module "naming_compute" {
  source   = "../../modules/naming"
  for_each = var.compute_instances

  customer      = var.customer
  project       = var.project
  environment   = var.environment
  app_name      = var.app_name
  resource_type = "ec2_instance"
  name          = each.key # 맵의 key (예: "bastion", "batch" 등)
}

# 2. Key Pair 생성
module "compute_key" {
  source             = "terraform-aws-modules/key-pair/aws"
  version            = "2.0.3"
  for_each           = var.compute_instances
  
  key_name           = "${module.naming_compute[each.key].result}-key"
  create_private_key = true
}

# 3. EC2 인스턴스 생성
resource "aws_instance" "this" {
  for_each = var.compute_instances

  ami                         = data.aws_ami.amazon_linux_2023.id
  # 하드코딩 변수 제거: 맵에 정의된 instance_type 속성 사용
  instance_type               = each.value.instance_type
  
  subnet_id                   = module.vpc.public_subnets[0]
  # 보안 그룹도 같은 key("bastion")를 가진 것을 자동으로 매핑
  vpc_security_group_ids      = [module.generic_sg[each.key].security_group_id]
  associate_public_ip_address = true
  key_name                    = module.compute_key[each.key].key_pair_name

  tags = module.naming_compute[each.key].tags_with_name
}