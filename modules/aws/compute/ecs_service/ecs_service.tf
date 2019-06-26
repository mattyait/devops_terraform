
#
# SG - ECS
#

resource "aws_security_group" "ecs_sg" {
  name        = "ecs-${var.name}-${var.environment}"
  description = "${var.name}-${var.environment} container security group"
  vpc_id      = "${var.vpc_id}"

  tags = {
    Name        = "ecs-${var.name}-${var.environment}"
    Environment = "${var.environment}"
    Automation  = "Terraform"
  }
}

resource "aws_security_group_rule" "app_ecs_allow_outbound" {
  description       = "All outbound"
  security_group_id = "${aws_security_group.ecs_sg.id}"

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "app_ecs_allow_https_from_alb" {
  count = "${var.associate_alb}"

  description       = "Allow in ALB"
  security_group_id = "${aws_security_group.ecs_sg.id}"

  type                     = "ingress"
  from_port                = "${var.container_port}"
  to_port                  = "${var.container_port}"
  protocol                 = "tcp"
  source_security_group_id = "${var.alb_security_group}"
}

resource "aws_security_group_rule" "app_ecs_allow_health_check_from_alb" {
  count = "${var.associate_alb > 0 && var.container_health_check_port > 0 ? 1 : 0}"

  description       = "Allow in health check from ALB"
  security_group_id = "${aws_security_group.ecs_sg.id}"

  type                     = "ingress"
  from_port                = "${var.container_health_check_port}"
  to_port                  = "${var.container_health_check_port}"
  protocol                 = "tcp"
  source_security_group_id = "${var.alb_security_group}"
}

#
# IAM - instance (optional)
#

data "aws_iam_policy_document" "instance_role_policy_doc" {
  count = "${var.ecs_instance_role != "" ? 1 : 0}"

  statement {
    actions = [
      "ecs:DeregisterContainerInstance",
      "ecs:RegisterContainerInstance",
      "ecs:Submit*",
    ]

    resources = ["${var.ecs_cluster_arn}"]
  }

  statement {
    actions = [
      "ecs:UpdateContainerInstancesState",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ecs:cluster"
      values   = ["${var.ecs_cluster_arn}"]
    }
  }

  statement {
    actions = [
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:StartTelemetrySession",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["${aws_cloudwatch_log_group.main.arn}"]
  }

  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]

    resources = ["${var.ecr_repo_arns}"]
  }
}

resource "aws_iam_role_policy" "instance_role_policy" {
  count = "${var.ecs_instance_role != "" ? 1 : 0}"

  name   = "${var.ecs_instance_role}-policy"
  role   = "${var.ecs_instance_role}"
  policy = "${data.aws_iam_policy_document.instance_role_policy_doc.json}"
}

#
# IAM - task
#

data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "task_execution_role_policy_doc" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["${aws_cloudwatch_log_group.main.arn}"]
  }

  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]

    resources = ["${var.ecr_repo_arns}"]
  }
}

resource "aws_iam_role" "task_role" {
  name               = "ecs-task-role-${var.name}-${var.environment}"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_assume_role_policy.json}"
}

resource "aws_iam_role" "task_execution_role" {
  count = "${var.ecs_use_fargate ? 1 : 0}"

  name               = "ecs-task-execution-role-${var.name}-${var.environment}"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_assume_role_policy.json}"
}

resource "aws_iam_role_policy" "task_execution_role_policy" {
  count = "${var.ecs_use_fargate ? 1 : 0}"

  name   = "${aws_iam_role.task_execution_role.name}-policy"
  role   = "${aws_iam_role.task_execution_role.name}"
  policy = "${data.aws_iam_policy_document.task_execution_role_policy_doc.json}"
}

#
# ECS
#

data "aws_region" "current" {}

# Create a task definition with a golang image so the ecs service can be easily
# tested. We expect deployments will manage the future container definitions.
resource "aws_ecs_task_definition" "main" {
  family        = "${var.name}-${var.environment}"
  network_mode  = "awsvpc"
  task_role_arn = "${aws_iam_role.task_role.arn}"

  # Fargate requirements
  requires_compatibilities = "${compact(list(var.ecs_use_fargate ? "FARGATE" : ""))}"
  cpu                      = "${var.ecs_use_fargate ? var.fargate_task_cpu : ""}"
  memory                   = "${var.ecs_use_fargate ? var.fargate_task_memory : ""}"
  execution_role_arn       = "${join("", aws_iam_role.task_execution_role.*.arn)}"

  container_definitions = "${var.container_definitions == "" ? local.default_container_definitions : var.container_definitions}"

  lifecycle {
    ignore_changes = [
      "requires_compatibilities",
      "cpu",
      "memory",
      "execution_role_arn",
      "container_definitions",
    ]
  }
}

# Create a data source to pull the latest active revision from
data "aws_ecs_task_definition" "main" {
  task_definition = "${aws_ecs_task_definition.main.family}"
  depends_on      = ["aws_ecs_task_definition.main"]         # ensures at least one task def exists
}

locals {
  ecs_service_launch_type = "${var.ecs_use_fargate ? "FARGATE" : "EC2"}"

  ecs_service_ordered_placement_strategy = {
    EC2 = [
      {
        type  = "spread"
        field = "attribute:ecs.availability-zone"
      },
      {
        type  = "spread"
        field = "instanceId"
      },
    ]

    FARGATE = []
  }

  ecs_service_placement_constraints = {
    EC2 = [{
      type = "distinctInstance"
    }]

    FARGATE = []
  }
}

resource "aws_ecs_service" "main" {
  count = "${var.associate_alb || var.associate_nlb ? 1 : 0}"

  name    = "${var.name}"
  cluster = "${var.ecs_cluster_arn}"

  launch_type = "${local.ecs_service_launch_type}"

  # Use latest active revision
  task_definition = "${aws_ecs_task_definition.main.family}:${max(
    "${aws_ecs_task_definition.main.revision}",
    "${data.aws_ecs_task_definition.main.revision}")}"

  desired_count                      = "${var.tasks_desired_count}"
  deployment_minimum_healthy_percent = "${var.tasks_minimum_healthy_percent}"
  deployment_maximum_percent         = "${var.tasks_maximum_percent}"

  ordered_placement_strategy = "${local.ecs_service_ordered_placement_strategy[local.ecs_service_launch_type]}"
  placement_constraints      = "${local.ecs_service_placement_constraints[local.ecs_service_launch_type]}"

  network_configuration {
    subnets          = ["${var.ecs_subnet_ids}"]
    security_groups  = ["${aws_security_group.ecs_sg.id}"]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = "${var.lb_target_group}"
    container_name   = "${local.target_container_name}"
    container_port   = "${var.container_port}"
  }

  lifecycle {
    ignore_changes = ["task_definition"]
  }
}

# XXX: We have to duplicate this resource with a count instead of parameterizing
# the load_balancer argument due to this Terraform bug:
# https://github.com/hashicorp/terraform/issues/16856
resource "aws_ecs_service" "main_no_lb" {
  count = "${var.associate_alb || var.associate_nlb ? 0 : 1}"

  name    = "${var.name}"
  cluster = "${var.ecs_cluster_arn}"

  launch_type = "${local.ecs_service_launch_type}"

  # Use latest active revision
  task_definition = "${aws_ecs_task_definition.main.family}:${max(
    "${aws_ecs_task_definition.main.revision}",
    "${data.aws_ecs_task_definition.main.revision}")}"

  desired_count                      = "${var.tasks_desired_count}"
  deployment_minimum_healthy_percent = "${var.tasks_minimum_healthy_percent}"
  deployment_maximum_percent         = "${var.tasks_maximum_percent}"

  ordered_placement_strategy = "${local.ecs_service_ordered_placement_strategy[local.ecs_service_launch_type]}"
  placement_constraints      = "${local.ecs_service_placement_constraints[local.ecs_service_launch_type]}"

  network_configuration {
    subnets          = ["${var.ecs_subnet_ids}"]
    security_groups  = ["${aws_security_group.ecs_sg.id}"]
    assign_public_ip = false
  }

  lifecycle {
    ignore_changes = ["task_definition"]
  }
}