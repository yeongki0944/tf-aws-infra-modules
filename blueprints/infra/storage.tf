# =============================================================
# S3 Buckets (General Pattern)
# =============================================================

resource "aws_s3_bucket" "this" {
  for_each = toset(["loki-chunks", "loki-ruler"])

  # ★ 조회 키: cluster_name 기반 (eks-addon에서 이 이름으로 찾음)
  bucket = "${var.cluster_name}-${each.key}"

  force_destroy = var.s3_force_destroy

  tags = merge(local.common_tags, {
    Name    = "${var.cluster_name}-${each.key}"
    Purpose = each.key
  })
}

# S3 보안 설정
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# =============================================================
# ECR Repositories
# =============================================================

resource "aws_ecr_repository" "this" {
  for_each = toset(var.ecr_repositories)

  name = each.key

  tags = local.common_tags
}