# =============Creating VPC==========================
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr_block}"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags
  )
}
