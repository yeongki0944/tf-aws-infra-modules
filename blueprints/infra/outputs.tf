# VPC
output "vpc_id"          { value = module.vpc.vpc_id }
output "vpc_cidr"        { value = module.vpc.vpc_cidr_block }
output "private_subnets" { value = module.vpc.private_subnets }

# Storage
output "s3_bucket_ids" {
  description = "Created S3 bucket IDs"
  value       = { for k, v in aws_s3_bucket.this : k => v.id }
}

output "ecr_repository_urls" {
  description = "ECR repository URLs"
  value       = { for k, v in aws_ecr_repository.this : k => v.repository_url }
}

# Bastion (참조 이름 수정: aws_instance.this["bastion"])
output "bastion_public_ip" {
  value = aws_instance.this["bastion"].public_ip
}

output "bastion_private_key" {
  value     = module.compute_key["bastion"].private_key_pem
  sensitive = true
}

# DNS & Context
output "zone_id"     { value = local.zone_id }
output "domain_name" { value = local.domain_name }
output "common_tags" { value = local.common_tags }