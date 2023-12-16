
output "argocd_url" {
  value = "http://argocd.${var.prefix}.${var.domain}, admin, password123"
}

output "jenkins_url" {
  value = "http://jenkins.${var.prefix}.${var.domain}, admin, password123"
}