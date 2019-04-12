provider "aws" {
  region                   = "${var.aws_region}"
  shared_credentials_file  = "/root/.aws/credentials"
  profile                  = "${var.aws_profile}"
  version = "1.1"
}

module "vpc" {
    source = "./modules/aws/vpc"
    vpc_name = "${var.vpc_name}"
    vpc_cidr_block = "${var.vpc_cidr_block}"
    private_subnet = "${var.private_subnet}"
    public_subnet = "${var.public_subnet}"
}
