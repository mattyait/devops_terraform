resource "aws_security_group" "security_group" {
  name        = "${var.security_group_name}"
  vpc_id      = "${var.vpc_id}"
  description = "Used in ${var.environment} for ${var.description}"

  tags = {
    Name        = "${var.environment}_${var.description}"
  }
}

resource "aws_security_group_rule" "security_group_ingress_rules" {
  type              = "ingress"
  count             = "${var.create}" ? length("${var.ingress_cidr_blocks}") : 0
  security_group_id = "${aws_security_group.security_group.id}"
  from_port         = "${var.ingress_cidr_blocks[count.index]["from_port"]}"
  to_port           = "${var.ingress_cidr_blocks[count.index]["to_port"]}"
  protocol          = "${var.ingress_cidr_blocks[count.index]["protocol"]}"
  description       = "${var.ingress_cidr_blocks[count.index]["description"]}"
  cidr_blocks       = "${var.ingress_cidr_blocks[count.index]["cidr_blocks"]}"
}

resource "aws_security_group_rule" "security_group_egress_rules" {
  type              = "egress"
  count             = "${var.create}" ? length("${var.egress_cidr_blocks}") : 0
  security_group_id = "${aws_security_group.security_group.id}"
  from_port         = "${var.egress_cidr_blocks[count.index]["from_port"]}"
  to_port           = "${var.egress_cidr_blocks[count.index]["to_port"]}"
  protocol          = "${var.egress_cidr_blocks[count.index]["protocol"]}"
  description       = "${var.egress_cidr_blocks[count.index]["description"]}"
  cidr_blocks       = "${var.egress_cidr_blocks[count.index]["cidr_blocks"]}"
}
