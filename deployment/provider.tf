provider "aws" {
  region                  = "${var.aws_region}"
  shared_credentials_file = "/root/.aws/credentials"
  profile                 = "${var.aws_profile}"
  version                 = ">= 2.19.0"
}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name           = "${var.dynamo_db_lock}"
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
