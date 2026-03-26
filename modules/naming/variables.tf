# tf-aws-infra-modules/modules/naming/variables.tf

variable "customer" {
  description = "고객사 식별 코드 (예: mzc) "
  type        = string
}

variable "project" {
  description = "프로젝트 명칭 (예: edu, portal) "
  type        = string
}

variable "environment" {
  description = "배포 환경 (예: dev, stg, prd) "
  type        = string
}

variable "app_name" {
  description = "서비스 단위 (예: eks, mall) "
  type        = string
}

variable "resource_type" {
  description = "리소스 종류 (예: virtual_private_cloud, security_group) [cite: 9, 10]"
  type        = string
}

variable "name" {
  description = "리소스의 구체적인 용도 (예: bastion, public) "
  type        = string
}