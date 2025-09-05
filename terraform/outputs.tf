output "node_group_arns" {
  value = module.eks.node_groups["managed_nodes"].iam_role_arn
}

output "ecr_repo" {
  value = aws_ecr_repository.flask_repo.repository_url
}

output "s3_bucket" {
  value = aws_s3_bucket.uploads.id
}

