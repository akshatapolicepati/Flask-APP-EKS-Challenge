##############################
# VPC Module
##############################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"  # ✅ Downgraded to a stable version

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a","us-east-1b","us-east-1c"]
  private_subnets = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24","10.0.102.0/24","10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

#############################
# EKS Module
##############################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0"   # ✅ Most stable with AWS provider 5.x

  cluster_name    = var.cluster_name
  cluster_version = "1.27"

  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id

  manage_aws_auth = true
  manage_iam_role = true

  node_groups = {
    managed_nodes = {
      desired_capacity = var.desired_capacity
      min_capacity     = var.min_size
      max_capacity     = var.max_size

      instance_types = [var.node_instance_type]
      disk_size      = 20

      additional_tags = {
        "Name" = "${var.cluster_name}-managed"
      }
    }
  }
}

##############################
# ECR Repository
##############################
resource "aws_ecr_repository" "flask_repo" {
  name = var.ecr_repo_name

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = var.ecr_repo_name
  }
}

##############################
# S3 Bucket
##############################
resource "aws_s3_bucket" "uploads" {
  bucket = var.s3_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_acl" "uploads_acl" {
  bucket = aws_s3_bucket.uploads.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "uploads_enc" {
  bucket = aws_s3_bucket.uploads.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

##############################
# Outputs
##############################
output "cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = module.eks.cluster_endpoint
}

output "kubeconfig_certificate_authority_data" {
  description = "EKS Cluster CA Data"
  value       = module.eks.cluster_certificate_authority_data
}

output "ecr_repo_url" {
  description = "ECR Repository URL"
  value       = aws_ecr_repository.flask_repo.repository_url
}

output "s3_bucket_name" {
  description = "S3 Bucket Name"
  value       = aws_s3_bucket.uploads.bucket
}

