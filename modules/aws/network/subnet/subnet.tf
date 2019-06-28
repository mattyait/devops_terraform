resource "aws_subnet" "subnet" {
  cidr_block              = "${var.cidr_block}"
  vpc_id                  = "${var.vpc_id}"
  availability_zone       = "${var.availability_zone}"
  tags = {
    Name        = "${var.environment}_${var.type}"
  }
}
