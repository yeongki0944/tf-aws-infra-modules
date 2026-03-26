# Global & Environment Context (Makefile로부터 주입됨)
variable "customer" {
  type        = string
  description = "고객사 식별 코드 (예: mzc, visang)"
}

variable "project" {
  type        = string
  description = "프로젝트 명칭 (예: allviaCL, edu-platform)"
}

variable "environment" {
  type        = string
  description = "배포 환경 구분 (예: dev, stg, prd)"
}

variable "app_name" {
  type        = string
  description = "애플리케이션 또는 서비스 명칭 (예: eduTech)"
}

# EKS Managed Node Group Spec
variable "node_groups" {
  type = map(object({
    instance_types = list(string)
    capacity_type  = string # ON_DEMAND 또는 SPOT
    min_size       = number
    max_size       = number
    desired_size   = number
    disk_size      = number
    labels         = map(string)
  }))
  description = "EKS 매니지드 노드 그룹 상세 설정 맵"
  default     = {}
}