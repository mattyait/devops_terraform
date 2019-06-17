# =============Creating Autoscaling Group===============
resource "aws_autoscaling_group" "asg" {
  availability_zones        = ["${split(",", var.availability_zones)}"]
  name                      = "${var.asg_name}"
  max_size                  = "${var.asg_max}"
  min_size                  = "${var.asg_min}"
  health_check_grace_period = "${var.health_check_grace_period}"
  desired_capacity          = "${var.asg_desired}"
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.asg-lc.name}"
  load_balancers            = ["${var.elb_name}"]

  tag {
    key                 = "Name"
    value               = "asg-${terraform.workspace}"
    propagate_at_launch = "true"
  }
}

# =============Creating Launch Configuration===============
resource "aws_launch_configuration" "asg-lc" {
  name_prefix     = "${var.launch_config_name}"
  image_id        = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type   = "${var.instance_type}"
  key_name        = "${var.keyname}"
  security_groups = ["${var.security_groups}"]
}
