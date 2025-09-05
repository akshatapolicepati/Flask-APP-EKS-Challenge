output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "kubeconfig_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "ecr_repo_url" {
  value = aws_ecr_repository.flask_repo.repository_url
}

output "s3_bucket_name" {
  value = aws_s3_bucket.uploads.bucket
}

