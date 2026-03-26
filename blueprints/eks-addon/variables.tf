variable "project" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (dev/prd)"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "domain_name" {
  description = "Route53 domain name"
  type        = string
}

# Karpenter
variable "karpenter_version" {
  description = "Karpenter Helm chart version"
  type        = string
}

# ArgoCD
variable "argocd_version" {
  description = "ArgoCD Helm chart version"
  type        = string
}

# IRSA (IAM Roles for Service Accounts) 동적 생성 맵
variable "custom_irsas" {
  description = "생성할 Custom IRSA 목록 (Loki, OpenCost 등)"
  type = map(object({
    namespace              = string
    service_account        = string
    # 직접 인라인 정책을 붙일 경우
    inline_policy_json     = optional(string)
    # AWS Managed Policy ARN을 붙일 경우
    managed_policy_arns    = optional(list(string), [])
  }))
  default = {}
}

# Helm Chart 버전 및 값 설정
variable "helm_charts" {
  description = "Helm Chart 관련 동적 설정 (Karpenter, ArgoCD 등)"
  type = map(object({
    enabled       = bool
    chart_version = string
    values_files  = optional(list(string), [])
  }))
  default = {}
}

variable "s3_bucket_names" {
  description = "Addon에서 사용할 기존 S3 버킷 이름 목록 (Key-Value 형식)"
  type        = map(string)
  default     = {}
}