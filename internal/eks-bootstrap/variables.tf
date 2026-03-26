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

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "ap-southeast-1"
}

# GitOps
variable "gitops_repo_url" {
  description = "ArgoCD GitOps repository URL"
  type        = string
}

variable "gitops_repo_branch" {
  description = "GitOps repository branch"
  type        = string
  default     = "main"
}

variable "gitops_repo_private" {
  description = "Whether the gitops repo is private"
  type        = bool
  default     = false
}

variable "gitops_repo_username" {
  description = "GitOps repo username (private repo only)"
  type        = string
  default     = ""
}

variable "gitops_repo_password" {
  description = "GitOps repo password/token (private repo only)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "allowed_source_repos" {
  description = "ArgoCD에서 허용할 소스 저장소 리스트"
  type        = list(string)
  default     = []
}

# Namespace
variable "argocd_namespaces" {
  description = "ArgoCD에서 관리할 네임스페이스 목록"
  type        = list(string)
  default     = ["monitoring", "loki", "middleware", "karpenter"]
}
