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
}

variable "app_name" {
  type        = string
  description = "서비스 명칭 (예: eks)"
}

# EKS Settings
variable "cluster_version" {
  type        = string
  description = "EKS 클러스터 버전"
  default     = "1.31"
}

variable "cluster_access_cidrs" {
  type        = list(string)
  description = "API 서버 접근 허용 CIDR"
  default     = ["0.0.0.0/0"]
}