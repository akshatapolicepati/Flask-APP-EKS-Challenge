# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.10.0"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24","10.0.102.0/24","10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

# EKS Module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.17.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  subnets = module.vpc.private_subnets
  vpc_id  = module.vpc.vpc_id

  manage_aws_auth = true

  eks_managed_node_groups = {
    managed_nodes = {
      desired_size = var.desired_capacity
      min_size     = var.min_size
      max_size     = var.max_size

      instance_types = [var.node_instance_type]
      disk_size      = 20

      labels = {
        role = "worker"
      }

      tags = {
        "Name" = "${var.cluster_name}-managed"
      }
    }
  }
}

# Create ECR Repo
resource "aws_ecr_repository" "flask_repo" {
  name = var.ecr_repo_name

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = var.ecr_repo_name
  }
}

# Create S3 Bucket
resource "aws_s3_bucket" "uploads" {
  bucket        = "${var.s3_bucket_name}-${random_id.suffix.hex}"
  force_destroy = true
}

resource "random_id" "suffix" {
  byte_length = 4
}

