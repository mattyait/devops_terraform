# ==========Create ALB Target Group==========
module "alb_target_group" {
  enable               = "${var.enable == "true" ? 1 : 0}"
  source               = "../../../../modules/aws/compute/alb_target_grp"
  target_group_name    = "${var.alb_target_group_name}"
  port                 = "${var.target_group_port}"
  protocol             = "${var.target_group_protocol}"
  vpc_id               = "${var.vpc_id}"
  deregistration_delay = "200"
  environment          = "${var.environment}"
  description          = "ecs_alb_tg"
}

resource "aws_s3_bucket" "lb_logs" {
  count  = "${var.enable == "true" ? 1 : 0}"
  bucket = "${var.aws_access_logs_bucket}"
  acl    = "private"

  tags = {
    Name        = "${var.aws_access_logs_bucket}"
    Environment = "${var.environment}"
  }
}

resource "aws_s3_bucket_policy" "lb_logs_policy" {
  count  = "${var.enable == "true" ? 1 : 0}"
  bucket = "${aws_s3_bucket.lb_logs[0].id}"

  policy = <<POLICY
{
  "Id": "Policy1429136655940",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1429136633762",
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.lb_logs[0].bucket}/*",
      "Principal": "*"
    }
  ]
}
POLICY
}

# ==========Create ALB ==========
resource "aws_lb" "load-balancer" {
  count              = "${var.is_access_logs_enabled == "true" && var.enable == "true" ? 1 : 0}"
  name               = "${var.lb_name}"
  internal           = "${var.is_internal_lb}"
  load_balancer_type = "${var.load_balancer_type}"
  security_groups    = "${var.security_groups}"
  subnets            = "${var.subnets}"

  enable_cross_zone_load_balancing = "${var.enable_cross_zone_load_balancing}"
  enable_deletion_protection       = "${var.deletion_protection}"

  access_logs {
    bucket  = "${aws_s3_bucket.lb_logs[0].bucket}"
    prefix  = "${var.sthree_logs_prefix}"
    enabled = true
  }

  tags = {
    Name = "${var.environment}_${var.type}"
  }
}

resource "aws_lb" "load-balancer-noaccess-logs" {
  count              = "${var.is_access_logs_enabled == "false" && var.enable == "true" ? 1 : 0}"
  name               = "${var.lb_name}"
  internal           = "${var.is_internal_lb}"
  load_balancer_type = "${var.load_balancer_type}"
  security_groups    = "${var.security_groups}"
  subnets            = "${var.subnets}"

  enable_cross_zone_load_balancing = "${var.enable_cross_zone_load_balancing}"
  enable_deletion_protection       = "${var.deletion_protection}"

  tags = {
    Name = "${var.environment}_${var.type}"
  }
}

# create a rule for ALB
resource "aws_lb_listener" "load-balancer" {
  count             = "${var.is_access_logs_enabled == "true" && var.enable == "true" ? 1 : 0}"
  load_balancer_arn = "${aws_lb.load-balancer[count.index].arn}"
  port              = "${var.alb_listener_port}"
  protocol          = "${var.alb_listener_protocol}"

  default_action {
    type             = "forward"
    target_group_arn = "${module.alb_target_group.alb_target_group_arn_out}"
  }
}

resource "aws_lb_listener" "load-balancer-noaccess-logs" {
  count             = "${var.is_access_logs_enabled == "false" && var.enable == "true" ? 1 : 0}"
  load_balancer_arn = "${aws_lb.load-balancer-noaccess-logs[count.index].arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${module.alb_target_group.alb_target_group_arn_out}"
  }
}

## ==========Attaching target group to ALB==========
#resource "aws_alb_target_group_attachment" "test" {
#  target_group_arn = "${module.alb_target_group.alb_target_group_arn_out}"
#  target_id        = "${module.alb_target_group.alb_target_group_id_out}"
#  port             = 80
#}

