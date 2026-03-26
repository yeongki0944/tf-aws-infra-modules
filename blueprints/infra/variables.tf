# MSP Naming Context
variable "customer" {
  type        = string
  description = "고객사 코드"
}

variable "project" {
  type        = string
  description = "프로젝트 명칭"
}

variable "environment" {
  type        = string
  description = "환경 (dev/stg/prd/shared)"
  validation {
    condition     = contains(["dev", "stg", "prd", "shared"], var.environment)
    error_message = "Environment must be one of: dev, stg, prd, shared."
  }
}

variable "app_name" {
  type        = string
  description = "서비스 명칭 (예: eks)"
}

# Network
variable "vpc_cidr" {
  type = string
}

variable "az_count" {
  type    = number
  default = 2
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

# DNS & Bastion
variable "domain_name" {
  type = string
}

variable "bastion_allow_ip" {
  type = string
}

variable "bastion_instance_type" {
  type    = string
  default = "t3.micro"
}

# Storage & ECR
variable "s3_force_destroy" {
  type    = bool
  default = true
}

variable "ecr_repositories" {
  type    = list(string)
  default = []
}

# Security Groups
variable "security_groups" {
  type = map(object({
    description = string
    ingress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      description = string
      cidr_blocks = string
    }))
  }))
  default = {}
}