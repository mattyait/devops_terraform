resource "aws_subnet" "subnet" {
  cidr_block              = "${var.cidr_block}"
  vpc_id                  = "${var.vpc_id}"
  
  tags = {
    Name        = "${var.environment}_${var.type}_${var.availability_zone}"
  }
}
