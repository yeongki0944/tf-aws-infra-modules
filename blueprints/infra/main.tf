# =============================================================
# VPC — 공식 모듈 (terraform-aws-vpc)
# =============================================================

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.16.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  public_subnets  = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 8, i)]
  private_subnets = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 8, i + var.az_count)]

  # NAT Gateway
  enable_nat_gateway   = var.single_nat_gateway ? true : true
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = true
  enable_dns_support   = true

  # VPC Flow Logs
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  # EKS 태그
  public_subnet_tags = {
    "kubernetes.io/role/elb"                       = 1
    "kubernetes.io/cluster/${var.cluster_name}"     = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"               = 1
    "kubernetes.io/cluster/${var.cluster_name}"     = "shared"
    "karpenter.sh/discovery"                        = var.cluster_name
  }

  tags = local.common_tags
}

# =============================================================
# Bastion EC2
# =============================================================

module "bastion_key" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "2.0.3"

  key_name           = "${var.cluster_name}-bastion-key"
  create_private_key = true

  tags = local.common_tags
}

# 범용 보안 그룹 생성 로직
module "generic_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"

  for_each = var.security_groups

  name        = "${var.cluster_name}-${each.key}"
  description = each.value.description
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = each.value.ingress_rules
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = local.common_tags
}
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.bastion_instance_type
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [module.bastion_sg.security_group_id]
  associate_public_ip_address = true
  key_name                    = module.bastion_key.key_pair_name

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-bastion"
  })
}

# =============================================================
# S3 — Loki 로그 저장용
# =============================================================

module "s3_loki_chunks" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.6.0"

  bucket        = "loki-${var.project}-chunks"
  force_destroy = var.s3_force_destroy

  versioning = { enabled = false }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  tags = merge(local.common_tags, { Purpose = "loki-chunks" })
}

module "s3_loki_ruler" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.6.0"

  bucket        = "loki-${var.project}-ruler"
  force_destroy = var.s3_force_destroy

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  tags = merge(local.common_tags, { Purpose = "loki-ruler" })
}

# =============================================================
# ECR
# =============================================================

module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "2.3.1"

  for_each = toset(var.ecr_repositories)

  repository_name                 = each.key
  repository_image_scan_on_push   = true
  repository_image_tag_mutability = "MUTABLE"

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = { type = "expire" }
      }
    ]
  })

  tags = local.common_tags
}
