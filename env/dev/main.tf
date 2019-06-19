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
  environment    = "${var.environment}"
}

module "public_subnet_1a" {
  source            = "../../modules/aws/subnet"
  vpc_id            = "${module.vpc.vpc_id_out}"
  cidr_block        = "${var.public_subnet_1a_cidr_block}"
  availability_zone = "ap-southeast-1a"
  environment       = "${var.environment}"
}

module "public_subnet_1b" {
  source            = "../../modules/aws/subnet"
  vpc_id            = "${module.vpc.vpc_id_out}"
  cidr_block        = "${var.public_subnet_1b_cidr_block}"
  availability_zone = "ap-southeast-1b"
  environment       = "${var.environment}"
}

module "private_subnet_1a" {
  source            = "../../modules/aws/subnet"
  vpc_id            = "${module.vpc.vpc_id_out}"
  cidr_block        = "${var.private_subnet_1a_cidr_block}"
  availability_zone = "ap-southeast-1a"
  environment       = "${var.environment}"
}

module "private_subnet_1b" {
  source            = "../../modules/aws/subnet"
  vpc_id            = "${module.vpc.vpc_id_out}"
  cidr_block        = "${var.private_subnet_1b_cidr_block}"
  availability_zone = "ap-southeast-1b"
  environment       = "${var.environment}"
}