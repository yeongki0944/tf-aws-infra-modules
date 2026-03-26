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

variable "vendor_module_path" {
  description = "vendor 모듈 기본 경로"
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
