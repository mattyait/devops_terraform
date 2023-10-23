resource "aws_route_table" "route_table" {
  count  = var.enable == "true" ? 1 : 0
  vpc_id = var.vpc_id
  lifecycle {
    ignore_changes = [route]
  }
  route {
    cidr_block = var.cidr_block
    gateway_id = var.gateway_id
  }
  tags = merge(var.tags)
}
