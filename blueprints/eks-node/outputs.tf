output "node_role_arn" {
  description = "생성된 노드 IAM Role의 ARN"
  value       = aws_iam_role.node.arn
}

output "node_role_name" {
  description = "생성된 노드 IAM Role의 이름"
  value       = aws_iam_role.node.name
}

output "node_groups" {
  description = "생성된 노드 그룹들의 상태 정보"
  value = {
    for k, v in aws_eks_node_group.this : k => {
      arn    = v.arn
      status = v.status
    }
  }
}