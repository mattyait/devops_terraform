# =============Creating VPC==========================
resource "aws_vpc" "Demoterraform" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  
  tags = {
    Name = "${var.vpc_name}-${var.env}"
  }
}

# =============Creating Internet Gateway==============
resource "aws_internet_gateway" "DemoInternetGateway" {
  vpc_id = "${aws_vpc.Demoterraform.id}"

  tags = {
    Name = "DemoInternetGateway-${var.env}"
  }
}

# =============Create Private Subnet for each availability_zone==============
resource "aws_subnet" "private" {
  vpc_id            = "${aws_vpc.Demoterraform.id}"
  cidr_block        = "${element(split(",", var.private_subnet), count.index)}"
  availability_zone = "${element(split(",", lookup(var.availability_zone, var.aws_region)), count.index)}"
  count             = "${length(compact(split(",", var.private_subnet)))}"

  tags = {
    Name = "private-${element(split(",", lookup(var.availability_zone, var.aws_region)), count.index)}-${var.env}"
  }
}

# =============Create Public Subnet for each availability_zone==============
resource "aws_subnet" "public" {
  vpc_id            = "${aws_vpc.Demoterraform.id}"
  cidr_block        = "${element(split(",", var.public_subnet), count.index)}"
  availability_zone = "${element(split(",", lookup(var.availability_zone, var.aws_region)), count.index)}"
  count             = "${length(compact(split(",", var.public_subnet)))}"

  tags = {
    Name = "public-${element(split(",", lookup(var.availability_zone, var.aws_region)), count.index)}-${var.env}"
  }
}

# =============Creating Public Route Table==============
resource "aws_route_table" "PublicRoute" {
  vpc_id = "${aws_vpc.Demoterraform.id}"

  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.DemoInternetGateway.id}"
  }

  tags = {
    Name = "Public RouteTable-${var.env}"
  }
}
