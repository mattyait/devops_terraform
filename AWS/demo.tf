provider "aws" {
  region                   = "${var.aws_region}"
  shared_credentials_file  = "/root/.aws/credentials"
  profile                  = "default"
}

resource "aws_vpc" "Demoterraform" {
    cidr_block = "${var.vpc_cidr_block}"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    tags {
        Name = "Demoterraform"
    }
}

resource "aws_subnet" "PrivateSubnetA" {
    vpc_id = "${aws_vpc.Demoterraform.id}"
    cidr_block = "${lookup(var.private_subnet, "subnetA")}"
    tags {
        Name = "PrivateSubnet1a"
    }
}

resource "aws_subnet" "PrivateSubnetB" {
    vpc_id = "${aws_vpc.Demoterraform.id}"
    cidr_block = "${lookup(var.private_subnet, "subnetB")}"
    tags {
        Name = "PrivateSubnet1b"
    }
}

resource "aws_subnet" "PublicSubnetA" {
    vpc_id = "${aws_vpc.Demoterraform.id}"
    cidr_block = "${lookup(var.public_subnet, "subnetA")}"

    tags {
        Name = "PublicSubnet1a"
    }
}
resource "aws_subnet" "PublicSubnetB" {
    vpc_id = "${aws_vpc.Demoterraform.id}"
    cidr_block = "${lookup(var.public_subnet, "subnetB")}"

    tags {
        Name = "PublicSubnet1b"
    }
}

resource "aws_internet_gateway" "DemoInternetGateway" {
    vpc_id = "${aws_vpc.Demoterraform.id}"

    tags {
        Name = "DemoInternetGateway"
    }
}

resource "aws_route_table" "PublicRouteA" {
    vpc_id = "${aws_vpc.Demoterraform.id}"
    route {
        cidr_block = "${var.public_route_cidr}"
        gateway_id = "${aws_internet_gateway.DemoInternetGateway.id}"
    }

    tags {
        Name = "Public"
    }
}
resource "aws_route_table" "PublicRouteB" {
    vpc_id = "${aws_vpc.Demoterraform.id}"
    route {
        cidr_block = "${var.public_route_cidr}"
        gateway_id = "${aws_internet_gateway.DemoInternetGateway.id}"
    }

    tags {
        Name = "Private"
    }
}
