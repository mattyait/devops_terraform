variable aws_profile  { default = "default" }
variable aws_region { default = "ap-southeast-2" }
variable vpc_name   { default = "" }
variable vpc_cidr_block { default = "" }
variable private_subnet { default = "" }
variable public_subnet  { default = "" }

provider "aws" {
  region                  = "${var.aws_region}"
  shared_credentials_file = "/root/.aws/credentials"
  profile                 = "${var.aws_profile}"
  version                 = "1.1"
}

module "vpc" {
  source         = "../../modules/aws/vpc"
  vpc_name       = "${var.vpc_name}"
  vpc_cidr_block = "${var.vpc_cidr_block}"
  private_subnet = "${var.private_subnet}"
  public_subnet  = "${var.public_subnet}"
}