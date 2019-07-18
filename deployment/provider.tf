provider "aws" {
  region                  = "${var.aws_region}"
  shared_credentials_file = "/root/.aws/credentials"
  profile                 = "${var.aws_profile}"
  version = ">= 2.19.0"
}