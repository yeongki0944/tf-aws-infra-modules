# =============================================================
# VPC
# =============================================================

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = module.vpc.natgw_ids
}

# =============================================================
# S3 (Loki)
# =============================================================

output "loki_chunks_bucket" {
  description = "Loki chunks S3 bucket name"
  value       = module.s3_loki_chunks.s3_bucket_id
}

output "loki_ruler_bucket" {
  description = "Loki ruler S3 bucket name"
  value       = module.s3_loki_ruler.s3_bucket_id
}

# =============================================================
# ECR
# =============================================================

output "ecr_repository_urls" {
  description = "ECR repository URLs"
  value       = { for k, v in module.ecr : k => v.repository_url }
}

# =============================================================
# Bastion
# =============================================================

output "bastion_public_ip" {
  description = "Bastion EC2 public IP"
  value       = aws_instance.bastion.public_ip
}

output "bastion_private_key" {
  description = "Bastion SSH private key"
  value       = module.bastion_key.private_key_pem
  sensitive   = true
}

# =============================================================
# DNS (조회 결과 전달)
# =============================================================

output "zone_id" {
  description = "Route53 Zone ID"
  value       = local.zone_id
}

output "domain_name" {
  description = "Route53 Domain Name"
  value       = local.domain_name
}
