# =============================================================
# 공통
# =============================================================

variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (dev/prd)"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name (VPC/Subnet 태그에 사용)"
  type        = string
}

# =============================================================
# VPC
# =============================================================

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "az_count" {
  description = "Number of availability zones"
  type        = number
  default     = 2
}

variable "single_nat_gateway" {
  description = "단일 NAT Gateway 사용 여부 (dev: true, prd: false)"
  type        = bool
  default     = true
}

# =============================================================
# DNS
# =============================================================

variable "domain_name" {
  description = "Route53 domain name"
  type        = string
}

# =============================================================
# Bastion
# =============================================================

variable "bastion_allow_ip" {
  description = "Bastion SSH 허용 IP (CIDR)"
  type        = string
}

variable "bastion_instance_type" {
  description = "Bastion EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# =============================================================
# S3
# =============================================================

variable "s3_force_destroy" {
  description = "S3 bucket force destroy (dev: true, prd: false)"
  type        = bool
  default     = true
}

# =============================================================
# ECR
# =============================================================

variable "ecr_repositories" {
  description = "List of ECR repository names"
  type        = list(string)
  default     = []
}
