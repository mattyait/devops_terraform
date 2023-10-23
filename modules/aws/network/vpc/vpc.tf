# =============Creating VPC==========================
resource "aws_vpc" "vpc" {
  count                = var.enable == "true" ? 1 : 0
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags
  )
}
