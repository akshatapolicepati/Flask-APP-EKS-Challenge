variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_name" {
  type    = string
  default = "eks-cluster"
}

variable "aws_account_id" {
  type = string
}

variable "ecr_repo_name" {
  type = string
  default = "eks-challenge-repo"
}

variable "s3_bucket_name" {
  type = string
  default = "ekschallengebucket123"
}

variable "node_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 3
}

