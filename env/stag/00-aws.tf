provider "aws" {
  region                  = "${var.aws_region}"
  shared_credentials_file = "/root/.aws/credentials"
  profile                 = "${var.aws_profile}"
  version                 = "2.7.0"
}

#resource "aws_s3_bucket" "bucket" {
#  bucket = "terraformbackend_matty.com"
#}

#terraform {
#  backend "s3" {
#    bucket = "terraformbackend_matty.com"
#    key    = "terraform"
#    region = "${var.aws_region}"
#  }
#}