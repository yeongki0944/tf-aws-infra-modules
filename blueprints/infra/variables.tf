# =============================================================
# MSP Naming Context
# =============================================================
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

# =============================================================
# Cluster Context (레이어 간 조회 키)
# =============================================================
variable "cluster_name" {
  type        = string
  description = "EKS 클러스터 이름 — 모든 리소스 Name 태그의 기준이 되는 조회 키"
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
  description = "생성할 EC2 인스턴스 목록"
  type = map(object({
    instance_type = string
  }))
  default = {}
}

variable "security_groups" {
  description = "생성할 보안 그룹 및 규칙 정의"
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
# Storage & ECR
# =============================================================
variable "s3_force_destroy" {
  type    = bool
  default = true
}

variable "ecr_repositories" {
  type    = list(string)
  default = []
}