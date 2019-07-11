/**
 * Creates an ECS service.
 *
 * Creates the following resources:
 *
 * * CloudWatch log group.
 * * Security Groups for the ECS service.
 * * ECS service.
 * * Task definition using `golang:1.12.5-alpine` (see below).
 * * Configurable associations with Network Load Balancers (NLB) and Application Load Balancers (ALB).
 *
 * We create an initial task definition using the `golang:1.12.5-alpine` image as a way
 * to validate the initial infrastructure is working: visiting the site shows
 * a simple Go hello world page. We expect deployments to manage the container
 * definitions going forward, not Terraform.
 *
 */

locals {
  awslogs_group         = "${var.logs_cloudwatch_group == "" ? "/ecs/${var.environment}/${var.name}" : var.logs_cloudwatch_group}"
  target_container_name = "${var.target_container_name == "" ? "${var.name}-${var.environment}" : var.target_container_name}"

  default_container_definitions = <<EOF
[
  {
    "name": "${local.target_container_name}",
    "image": "${var.container_image}",
    "cpu": 256,
    "memory": 256,
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${var.container_port},
        "hostPort": ${var.host_port},
        "protocol": "tcp"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${local.awslogs_group}",
        "awslogs-region": "${data.aws_region.current.name}",
        "awslogs-stream-prefix": "helloworld"
      }
    },
    "environment": [
      {
        "name": "PORT",
        "value": "${var.container_port}"
      }
    ],
    "mountPoints": [],
    "volumesFrom": [],
    "entryPoint": []
  }
]
EOF
}

#
# CloudWatch
#

resource "aws_cloudwatch_log_group" "main" {
  name              = "${local.awslogs_group}"
  retention_in_days = "${var.logs_cloudwatch_retention}"

  tags = {
    Name        = "${var.name}-${var.environment}"
    Environment = "${var.environment}"
    Automation  = "Terraform"
  }
}

#
# SG - ECS
#

resource "aws_security_group" "ecs_sg" {
  name        = "ecs-${var.name}-${var.environment}"
  description = "${var.name}-${var.environment} container security group"
  vpc_id      = "${var.ecs_vpc_id}"

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
  count = "${var.associate_alb && var.container_port > 0 ? 1 : 0}"

  description       = "Allow in ALB"
  security_group_id = "${aws_security_group.ecs_sg.id}"

  type                     = "ingress"
  from_port                = "${var.container_port}"
  to_port                  = "${var.container_port}"
  protocol                 = "tcp"
  source_security_group_id = "${var.alb_security_group}"
}

resource "aws_security_group_rule" "app_ecs_allow_health_check_from_alb" {
  count = "${var.associate_alb && var.container_health_check_port > 0 ? 1 : 0}"
  

  description       = "Allow in health check from ALB"
  security_group_id = "${aws_security_group.ecs_sg.id}"

  type                     = "ingress"
  from_port                = "${var.container_health_check_port}"
  to_port                  = "${var.container_health_check_port}"
  protocol                 = "tcp"
  source_security_group_id = "${var.alb_security_group}"
}

resource "aws_security_group_rule" "app_ecs_allow_tcp_from_nlb" {
  count = "${var.associate_nlb && var.container_port > 0 ? 1 : 0}"

  description       = "Allow in NLB"
  security_group_id = "${aws_security_group.ecs_sg.id}"

  type        = "ingress"
  from_port   = "${var.container_port}"
  to_port     = "${var.container_port}"
  protocol    = "tcp"
  cidr_blocks = "${var.nlb_subnet_cidr_blocks}"
}

resource "aws_security_group_rule" "app_ecs_allow_health_check_from_nlb" {
  count = "${var.associate_nlb && var.container_health_check_port > 0 ? 1 : 0}"

  description       = "Allow in health check from NLB"
  security_group_id = "${aws_security_group.ecs_sg.id}"

  type        = "ingress"
  from_port   = "${var.container_health_check_port}"
  to_port     = "${var.container_health_check_port}"
  protocol    = "tcp"
  cidr_blocks = "${var.nlb_subnet_cidr_blocks}"
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

    resources = "${var.ecr_repo_arns}"
  }
}

resource "aws_iam_role_policy" "instance_role_policy" {
  count = "${var.ecs_instance_role != "" ? 1 : 0}"

  name   = "${var.ecs_instance_role}-policy"
  role   = "${var.ecs_instance_role}"
  #policy = "${data.aws_iam_policy_document.instance_role_policy_doc.json}"
  policy  = "${data.aws_iam_policy_document.instance_role_policy_doc[count.index].json}"
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

    resources = "${var.ecr_repo_arns}"
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
  #name   = "${aws_iam_role.task_execution_role.name}-policy"
  #role   = "${aws_iam_role.task_execution_role.name}"
  name   = "${aws_iam_role.task_execution_role[count.index].name}-policy"
  role   = "${aws_iam_role.task_execution_role[count.index].name}"
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
  network_mode  = "${var.ecs_task_def_network_mode}"
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
    #EC2 = [{
    #  type = "memberOf"
    #}]
    EC2 = []

    FARGATE = []
  }
}

resource "aws_ecs_service" "main" {

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

  dynamic "ordered_placement_strategy" {
    for_each = local.ecs_service_ordered_placement_strategy[local.ecs_service_launch_type]
    content {
      type = ordered_placement_strategy.value.type
      field = ordered_placement_strategy.value.field
    }
  }
  dynamic "placement_constraints" {
    for_each = local.ecs_service_placement_constraints[local.ecs_service_launch_type]
    content {
      type = placement_constraints.value.type
    }
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

# Application AutoScaling resources
#
resource "aws_appautoscaling_target" "main" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = "${var.min_count}"
  max_capacity       = "${var.max_count}"

  depends_on = [
    "aws_ecs_service.main",
  ]
}

resource "aws_appautoscaling_policy" "up" {
  name               = "appScalingPolicy${var.environment}${var.name}ScaleUp"
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = "${var.scale_up_cooldown_seconds}"
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [
    "aws_appautoscaling_target.main",
  ]
}

resource "aws_appautoscaling_policy" "down" {
  name               = "appScalingPolicy${var.environment}${var.name}ScaleDown"
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = "${var.scale_down_cooldown_seconds}"
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [
    "aws_appautoscaling_target.main",
  ]
}