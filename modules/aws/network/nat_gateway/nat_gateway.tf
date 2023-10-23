resource "aws_eip" "nat_gateway_ip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_ip.id
  subnet_id     = var.subnet_id

  tags = merge(var.tags)
}
