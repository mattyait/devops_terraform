provider "aws" {
  version                 = "1.1"
  region                  = "${var.aws_region}"
  shared_credentials_file = "/root/.aws/credentials"
  profile                 = "${var.aws_profile}"
}

# =============Creating VPC==========================
resource "aws_vpc" "Demoterraform" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags {
    Name = "${var.vpc_name}"
  }
}

# =============Creating Private Subnet1a==============
resource "aws_subnet" "PrivateSubnetA" {
  vpc_id     = "${aws_vpc.Demoterraform.id}"
  cidr_block = "${lookup(var.private_subnet, "subnetA")}"

  tags {
    Name = "PrivateSubnet1a"
  }
}

# =============Creating Private Subnet1b==============
resource "aws_subnet" "PrivateSubnetB" {
  vpc_id     = "${aws_vpc.Demoterraform.id}"
  cidr_block = "${lookup(var.private_subnet, "subnetB")}"

  tags {
    Name = "PrivateSubnet1b"
  }
}

# =============Creating Public Subnet1a==============
resource "aws_subnet" "PublicSubnetA" {
  vpc_id     = "${aws_vpc.Demoterraform.id}"
  cidr_block = "${lookup(var.public_subnet, "subnetA")}"

  tags {
    Name = "PublicSubnet1a"
  }
}

# =============Creating Public Subnet1b==============
resource "aws_subnet" "PublicSubnetB" {
  vpc_id     = "${aws_vpc.Demoterraform.id}"
  cidr_block = "${lookup(var.public_subnet, "subnetB")}"

  tags {
    Name = "PublicSubnet1b"
  }
}

# =============Creating Internet Gateway==============
resource "aws_internet_gateway" "DemoInternetGateway" {
  vpc_id = "${aws_vpc.Demoterraform.id}"

  tags {
    Name = "DemoInternetGateway"
  }
}

# =============Creating Public Route Table==============
resource "aws_route_table" "PublicRoute" {
  vpc_id = "${aws_vpc.Demoterraform.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.DemoInternetGateway.id}"
  }

  tags {
    Name = "Public RouteTable"
  }
}
