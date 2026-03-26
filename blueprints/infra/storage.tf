# S3 네이밍 (예: Loki용)
module "naming_s3" {
  source = "../../modules/naming"
  for_each = toset(["loki-storage"])

  customer      = var.customer
  project       = var.project
  environment   = var.environment
  app_name      = var.app_name
  resource_type = "s3_bucket"
  name          = each.key
}

resource "aws_s3_bucket" "this" {
  for_each = module.naming_s3
  bucket   = each.value.result
  tags     = each.value.tags
}

# ECR 리포지토리 (단순 이름만 필요하므로 common_tags 활용)
resource "aws_ecr_repository" "this" {
  for_each = toset(var.ecr_repositories)
  name     = each.key
  tags     = local.common_tags
}