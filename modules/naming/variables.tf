# modules/naming/variables.tf

variable "customer" {
  description = "고객사 식별 코드 (예: bsg, acme)"
  type        = string
}

variable "project" {
  description = "프로젝트 명칭 (예: edu, portal)"
  type        = string
}

variable "environment" {
  description = "배포 환경 (예: dev, stg, prd, shared)"
  type        = string
}

variable "app_name" {
  description = "어플리케이션 또는 서비스 단위 (예: eks, mall, data)"
  type        = string
}

variable "resource_type" {
  description = "리소스 종류 (예: virtual_private_cloud, security_group). main.tf의 사전(Map) 키값과 일치해야 함"
  type        = string
}

variable "name" {
  description = "리소스의 구체적인 용도 또는 순번 (예: bastion, public, 01)"
  type        = string
}