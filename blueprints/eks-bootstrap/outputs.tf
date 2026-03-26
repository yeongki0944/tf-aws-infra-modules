output "argocd_url" {
  description = "ArgoCD UI URL (kubectl로 확인)"
  value       = "kubectl get svc -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

output "argocd_password_cmd" {
  description = "ArgoCD 초기 비밀번호 확인 명령어"
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}
