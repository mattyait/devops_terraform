resource "aws_launch_configuration" "ecs-launch-configuration" {
    name                        = "${var.launch_config_name}"
    image_id                    = "${var.image_id}"
    instance_type               = "${var.instance_type}"
    iam_instance_profile        = "${var.iam_instance_profile_id}"

    root_block_device {
      volume_type = "${var.volume_type}"
      volume_size = "${var.volume_size}"
      delete_on_termination = "${var.is_delete_on_termination}"
    }

    lifecycle {
      create_before_destroy = true
    }

    security_groups             = ["${aws_security_group.test_public_sg.id}"]
    associate_public_ip_address = "true"
    key_name                    = "${var.ecs_key_pair_name}"
    user_data                   = <<EOF
                                  #!/bin/bash
                                  echo ECS_CLUSTER=${var.ecs_cluster} >> /etc/ecs/ecs.config
                                  EOF
}