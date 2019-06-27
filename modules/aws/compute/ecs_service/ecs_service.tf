data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = var.trusted_role_arns
    }
  }
}

resource "aws_iam_role" "task_role" {
    name = "${var.ecs_iam_role_name}"
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy_attachment" "ecs_services_policy" {
    name = "ecs_services_policy-${var.environment}"
    roles = ["${aws_iam_role.task_role.name}"]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}


locals {

  default_container_definitions = <<EOF
[
  {
    "name": "first",
    "image": "service-first",
    "cpu": 10,
    "memory": 512,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  },
  {
    "name": "second",
    "image": "service-second",
    "cpu": 10,
    "memory": 256,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 443,
        "hostPort": 443
      }
    ]
  }
]
EOF
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family        = "${var.task_definition_name}-${var.environment}"
  network_mode  = "awsvpc"
  task_role_arn = "${aws_iam_role.task_role.arn}"

  # Fargate requirements if needs
  requires_compatibilities = "${compact(list(var.ecs_use_fargate ? "FARGATE" : ""))}"
  cpu                      = "${var.ecs_use_fargate ? var.fargate_task_cpu : ""}"
  memory                   = "${var.ecs_use_fargate ? var.fargate_task_memory : ""}"
  #execution_role_arn       = "${join("", aws_iam_role.task_execution_role.*.arn)}"

  container_definitions = "${var.default_container_definitions}"

  lifecycle {
    ignore_changes = [
      "requires_compatibilities",
      "cpu",
      "memory",
      "execution_role_arn",
      "container_definitions",
    ]
  }
  
  volume {
    name      = "service-storage"
    host_path = "/ecs/service-storage"
  }
}




#resource "aws_ecs_service" "ecs_service" {
#  name            = "mongodb"
#  cluster         = "${module.ecs_cluster.ecs_cluster_id_out}"
#  task_definition = "${aws_ecs_task_definition.ecs_task_definition.arn}"
#  desired_count   = 3
#  #iam_role        = "${aws_iam_role.foo.arn}"
#  #depends_on      = ["aws_iam_role_policy.foo"]

#  ordered_placement_strategy {
#    type  = "binpack"
#    field = "cpu"
#  }

#  load_balancer {
#    target_group_arn = "${aws_lb_target_group.foo.arn}"
#    container_name   = "mongo"
#    container_port   = 8080
#  }

#  placement_constraints {
#    type       = "memberOf"
#    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
#  }
#}

