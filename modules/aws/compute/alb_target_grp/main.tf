resource "aws_lb_target_group" "target_group" {
  count                = "${var.enable == "true" ? 1 : 0}"
  name                 = "${var.target_group_name}"
  port                 = "${var.port}"
  protocol             = "${var.protocol}"
  vpc_id               = "${var.vpc_id}"
  deregistration_delay = "${var.deregistration_delay}"

  tags = {
    Name = "${var.environment}_${var.description}"
  }
}
