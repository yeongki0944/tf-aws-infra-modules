output "node_role_arn" {
  description = "Node IAM Role ARN"
  value       = aws_iam_role.node.arn
}

output "node_role_name" {
  description = "Node IAM Role Name"
  value       = aws_iam_role.node.name
}

output "infra_ng_name" {
  description = "Infra Node Group name"
  value       = aws_eks_node_group.infra.node_group_name
}

output "infra_ng_status" {
  description = "Infra Node Group status"
  value       = aws_eks_node_group.infra.status
}
