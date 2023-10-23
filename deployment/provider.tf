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
