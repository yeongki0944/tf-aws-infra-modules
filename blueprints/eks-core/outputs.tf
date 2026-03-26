output "cluster_name" {
  description = "EKS Cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS Cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_ca" {
  description = "EKS Cluster CA certificate (base64)"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_version" {
  description = "EKS Cluster version"
  value       = module.eks.cluster_version
}

output "oidc_provider_arn" {
  description = "OIDC Provider ARN"
  value       = module.eks.oidc_provider_arn
}

output "oidc_issuer_url" {
  description = "OIDC Issuer URL (without https://)"
  value       = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
}

output "cluster_security_group_id" {
  description = "EKS Cluster security group ID"
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "EKS Node security group ID"
  value       = module.eks.node_security_group_id
}
