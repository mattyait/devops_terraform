terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.11.0"
    }
  }
  required_version = ">= 1.1"
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = module.eks[0].cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks[0].cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--region", var.aws_region, "--cluster-name", module.eks[0].cluster_name]
    command     = "aws"
  }
  ignore_annotations = []
}

provider "helm" {
  kubernetes {
    host                   = module.eks[0].cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks[0].cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--region", var.aws_region, "--cluster-name", module.eks[0].cluster_name]
      command     = "aws"
    }
  }
}
resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name           = var.dynamo_db_lock
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "DynamoDB Terraform State Lock Table"
  }
}
