resource "aws_internet_gateway" "internet_gateway" {
  count  = var.enable == "true" ? 1 : 0
  vpc_id = var.vpc_id
  tags   = merge(var.tags)
}
