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

# Infra Node Group
variable "infra_ng_instance_types" {
  description = "Infra NG instance types"
  type        = list(string)
}

variable "infra_ng_desired" {
  description = "Infra NG desired size"
  type        = number
}

variable "infra_ng_min" {
  description = "Infra NG min size"
  type        = number
}

variable "infra_ng_max" {
  description = "Infra NG max size"
  type        = number
}

variable "infra_ng_disk_size" {
  description = "Infra NG disk size (GB)"
  type        = number
  default     = 30
}
