resource "aws_s3_bucket" "this" {
  for_each = var.s3_names

  bucket        = each.value
  force_destroy = var.s3_force_destroy

  tags = merge(var.common_tags, {
    Name    = each.value
    Purpose = each.key
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = aws_s3_bucket.this
  bucket   = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = aws_s3_bucket.this
  bucket   = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_ecr_repository" "this" {
  for_each = toset(var.ecr_repositories)
  name     = each.key
  tags     = var.common_tags
}