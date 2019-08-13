resource "aws_security_group" "security_group" {
  count        = "${var.enable == "true" ? 1 : 0}"
  name        = "${var.security_group_name}"
  vpc_id      = "${var.vpc_id}"
  description = "Used in ${var.environment} for ${var.description}"

  tags = {
    Name        = "${var.environment}_${var.description}"
  }
}

resource "aws_security_group_rule" "security_group_ingress_rules" {
  type              = "ingress"
  count             = "${var.create && var.enable == "true"}" ? length("${var.ingress_cidr_blocks}") : 0
  security_group_id = "${aws_security_group.security_group[0].id}"
  from_port         = "${var.ingress_cidr_blocks[count.index]["from_port"]}"
  to_port           = "${var.ingress_cidr_blocks[count.index]["to_port"]}"
  protocol          = "${var.ingress_cidr_blocks[count.index]["protocol"]}"
  description       = "${var.ingress_cidr_blocks[count.index]["description"]}"
  cidr_blocks       = "${var.ingress_cidr_blocks[count.index]["cidr_blocks"]}"
}

resource "aws_security_group_rule" "ingress_with_source_security_group_id" {
  type              = "ingress"
  count             = "${var.create && var.enable == "true"}" ? length("${var.ingress_with_source_security_group_id}") : 0
  security_group_id = "${aws_security_group.security_group[0].id}"
  from_port         = "${var.ingress_with_source_security_group_id[count.index]["from_port"]}"
  to_port           = "${var.ingress_with_source_security_group_id[count.index]["to_port"]}"
  protocol          = "${var.ingress_with_source_security_group_id[count.index]["protocol"]}"
  description       = "${var.ingress_with_source_security_group_id[count.index]["description"]}"
  source_security_group_id = "${var.ingress_with_source_security_group_id[count.index]["source_security_group_id"]}"
}

resource "aws_security_group_rule" "security_group_egress_rules" {
  type              = "egress"
  count             = "${var.create && var.enable == "true"}" ? length("${var.egress_cidr_blocks}") : 0
  security_group_id = "${aws_security_group.security_group[0].id}"
  from_port         = "${var.egress_cidr_blocks[count.index]["from_port"]}"
  to_port           = "${var.egress_cidr_blocks[count.index]["to_port"]}"
  protocol          = "${var.egress_cidr_blocks[count.index]["protocol"]}"
  description       = "${var.egress_cidr_blocks[count.index]["description"]}"
  cidr_blocks       = "${var.egress_cidr_blocks[count.index]["cidr_blocks"]}"
}

resource "aws_security_group_rule" "egress_with_source_security_group_id" {
  type              = "egress"
  count             = "${var.create && var.enable == "true"}" ? length("${var.egress_with_source_security_group_id}") : 0
  security_group_id = "${aws_security_group.security_group[0].id}"
  from_port         = "${var.egress_with_source_security_group_id[count.index]["from_port"]}"
  to_port           = "${var.egress_with_source_security_group_id[count.index]["to_port"]}"
  protocol          = "${var.egress_with_source_security_group_id[count.index]["protocol"]}"
  description       = "${var.egress_with_source_security_group_id[count.index]["description"]}"
  source_security_group_id = "${var.egress_with_source_security_group_id[count.index]["source_security_group_id"]}"
}
