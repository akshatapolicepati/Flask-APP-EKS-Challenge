variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  default     = "flask-eks-cluster"
}

variable "node_instance_type" {
  description = "Instance type for worker nodes"
  default     = "t3.medium"
}

variable "min_size" {
  description = "Minimum number of nodes"
  default     = 1
}

variable "max_size" {
  description = "Maximum number of nodes"
  default     = 3
}

variable "desired_capacity" {
  description = "Desired node count"
  default     = 2
}

variable "ecr_repo_name" {
  description = "ECR repository name"
  default     = "flask-app"
}

variable "s3_bucket_name" {
  description = "S3 bucket name for uploads"
  default     = "flask-app-uploads"
}

