resource "aws_codebuild_project" "codebuild" {
  count        = var.enable == "true" ? 1 : 0
  name         = var.name
  description  = var.description
  service_role = var.service_role

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = var.cache_type
    location = var.cache_location
  }

  environment {
    type            = var.environment_type
    compute_type    = var.compute_type
    image           = var.image
    privileged_mode = var.privileged_mode

    dynamic "environment_variable" {
      for_each = var.environment_variables

      content {
        name  = environment_variable.value.name
        value = environment_variable.value.value
      }
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "codebuild"
      stream_name = var.name
    }
  }

  source {
    type            = var.source_provider
    location        = var.repository_url
    git_clone_depth = 1
  }

  build_timeout = var.build_timeout
  tags          = merge(var.tags)
}
