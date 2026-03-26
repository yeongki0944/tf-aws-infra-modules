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

variable "cluster_version" {
  description = "EKS cluster version"
  type        = string
}

variable "cluster_access_cidrs" {
  description = "EKS API server public access CIDRs"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "vendor_module_path" {
  description = "vendor 모듈 기본 경로"
  type        = string
}
