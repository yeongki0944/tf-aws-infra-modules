# Karpenter
output "karpenter_node_iam_role_name" {
  description = "Karpenter Node IAM Role Name"
  value       = module.eks_blueprints_addons.karpenter.node_iam_role_name
}

output "karpenter_queue_name" {
  description = "Karpenter SQS Queue Name"
  value       = module.eks_blueprints_addons.karpenter.sqs.queue_name
}

# Loki IRSA
output "loki_irsa_arn" {
  description = "Loki IRSA Role ARN"
  value       = module.loki_irsa.iam_role_arn
}

# OpenCost IRSA
output "opencost_irsa_arn" {
  description = "OpenCost IRSA Role ARN"
  value       = module.opencost_irsa.iam_role_arn
}

# S3 (passthrough from datasource)
output "loki_chunks_bucket" {
  description = "Loki chunks S3 bucket"
  value       = local.loki_chunks_bucket
}

output "loki_ruler_bucket" {
  description = "Loki ruler S3 bucket"
  value       = local.loki_ruler_bucket
}

# 참조용
output "cluster_name" {
  description = "EKS Cluster name"
  value       = local.cluster_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = local.vpc_id
}
