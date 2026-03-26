# modules/naming/outputs.tf

output "prefix" {
  description = "조합된 표준 프리픽스 (고객-프로젝트-환경-앱)"
  value       = local.prefix
}

output "result" {
  description = "최종 리소스 이름 (프리픽스-약어-용도)"
  value       = local.result
}

output "tags" {
  description = "MSP 표준 공통 태그 세트"
  value       = local.common_tags
}

output "tags_with_name" {
  description = "공통 태그에 Name 태그가 포함된 전체 태그 세트"
  value       = merge(local.common_tags, {
    Name = local.result
  })
}