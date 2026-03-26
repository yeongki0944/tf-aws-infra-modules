# tf-aws-infra-modules/modules/naming/outputs.tf

output "prefix" {
  description = "조합된 표준 프리픽스 "
  value       = module.remote_naming.prefix
}

output "result" {
  description = "최종 리소스 이름 "
  value       = module.remote_naming.result
}

output "tags" {
  description = "MSP 표준 공통 태그 세트 "
  value       = module.remote_naming.tags
}

output "tags_with_name" {
  description = "Name 태그가 포함된 전체 태그 세트 "
  value       = module.remote_naming.tags_with_name
}