# =============================================================
# 조회 키 & 태그 (deployment에서 주입)
# =============================================================
variable "cluster_name" {
  type        = string
  description = "레이어 간 조회 키"
}

variable "vpc_name" {
  type        = string
  description = "VPC Name 태그"
}

variable "sg_names" {
  type        = map(string)
  description = "Security Group Name 맵 (key=용도, value=전체 이름)"
}

variable "ec2_names" {
  type        = map(string)
  description = "EC2 Instance Name 맵"
}

variable "s3_names" {
  type        = map(string)
  description = "S3 Bucket Name 맵"
}

variable "common_tags" {
  type        = map(string)
  description = "MSP 표준 태그"
}

# =============================================================
# Network
# =============================================================
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

# =============================================================
# DNS
# =============================================================
variable "domain_name" {
  type = string
}

# =============================================================
# Compute & Security (General Pattern)
# =============================================================
variable "compute_instances" {
  type = map(object({
    instance_type = string
  }))
  default = {}
}

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

# =============================================================
# Storage
# =============================================================
variable "s3_force_destroy" {
  type    = bool
  default = true
}

variable "ecr_repositories" {
  type    = list(string)
  default = []
}