# =============Creating VPC==========================
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  
  tags = {
    Name = "${var.vpc_name}-${var.environment}"
  }
}

# =============Creating Internet Gateway==============
resource "aws_internet_gateway" "internetgateway" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "igw-${var.environment}"
  }
}
