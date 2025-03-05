output "nginx_service_ip" {
  value       = kubernetes_service.nginx.status[0].load_balancer[0].ingress[0].hostname
  description = "The public hostname of the NGINX service in AWS"
}

output "eks_cluster_endpoint" {
  value       = aws_eks_cluster.eks.endpoint
  description = "The endpoint of the EKS cluster"
}

output "eks_cluster_name" {
  value       = aws_eks_cluster.eks.name
  description = "The name of the EKS cluster"
}
