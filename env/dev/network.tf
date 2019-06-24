#======= Creating VPC=========
module "vpc" {
  source         = "../../modules/aws/vpc"
  vpc_name       = "${var.vpc_name}"
  vpc_cidr_block = "${var.vpc_cidr_block}"
  environment    = "${var.environment}"
}

#=======Creating internet Gateway ==========
module "internet_gateway"{
  source      = "../../modules/aws/internet_gateway"
  vpc_id      = "${module.vpc.vpc_id_out}"
  environment = "${var.environment}"
  type        = "igw"
}
  
#======= Creating Public Subnet in both 1a and 1b Availability_zone========================
module "public_subnet_1a" {
  source            = "../../modules/aws/subnet"
  vpc_id            = "${module.vpc.vpc_id_out}"
  cidr_block        = "${var.public_subnet_1a_cidr_block}"
  environment       = "${var.environment}"
  type              = "public_1a"
}

module "public_subnet_1b" {
  source            = "../../modules/aws/subnet"
  vpc_id            = "${module.vpc.vpc_id_out}"
  cidr_block        = "${var.public_subnet_1b_cidr_block}"
  environment       = "${var.environment}"
  type              = "public_1b"
}

#======= Creating Private Subnet in 1a Availability zone========================
#======= Creating Nat Gateway and attaching to private route for 1a zone=========
module "nat_gateway_1a" {
  source    = "../../modules/aws/nat_gateway"
  subnet_id = "${module.public_subnet_1a.subnet_id_out}"
  environment = "${var.environment}"
  type        = "public_1a"
}

module "private_subnet_1a" {
  source            = "../../modules/aws/subnet"
  vpc_id            = "${module.vpc.vpc_id_out}"
  cidr_block        = "${var.private_subnet_1a_cidr_block}"
  environment       = "${var.environment}"
  type              = "private_1a"
}

module "private_route_1a" {
  source         = "../../modules/aws/route_table"
  environment    = "${var.environment}"
  vpc_id         = "${module.vpc.vpc_id_out}"
  cidr_block     = "0.0.0.0/0"
  gateway_id     = "${module.nat_gateway_1a.nat_gateway_id}"
  type           = "private_1a"
}

#======= Creating Private Subnet in 1b Availability zone========================
#======= Creating Nat Gateway and attaching to priavte route for 1b zone=========
module "nat_gateway_1b" {
  source    = "../../modules/aws/nat_gateway"
  subnet_id = "${module.public_subnet_1b.subnet_id_out}"
  environment = "${var.environment}"
  type        = "public_1b"
}


module "private_subnet_1b" {
  source            = "../../modules/aws/subnet"
  vpc_id            = "${module.vpc.vpc_id_out}"
  cidr_block        = "${var.private_subnet_1b_cidr_block}"
  environment       = "${var.environment}"
  type              = "private_1b"
}

module "private_route_1b" {
  source         = "../../modules/aws/route_table"
  environment    = "${var.environment}"
  vpc_id         = "${module.vpc.vpc_id_out}"
  cidr_block     = "0.0.0.0/0"
  gateway_id     = "${module.nat_gateway_1b.nat_gateway_id}"
  type           = "private_1b"
}

#=========Public route table and attach to internet gateway_id
module "public_route" {
  source         = "../../modules/aws/route_table"
  environment    = "${var.environment}"
  vpc_id         = "${module.vpc.vpc_id_out}"
  cidr_block     = "0.0.0.0/0"
  gateway_id    = "${module.internet_gateway.internet_gateway_id_out}"
  type           = "public"
}
