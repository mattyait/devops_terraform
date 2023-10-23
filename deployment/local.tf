data "aws_availability_zones" "available" {}
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

locals {
  account_identifier = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}"
  azs                = slice(data.aws_availability_zones.available.names, 0, 3)
  tags = {
    Environment = terraform.workspace
    Created_By  = "terraform"
  }
}

