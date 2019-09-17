module "codeBuild" {
  enable           = "${var.codebuild_create}"
  source           = "../modules/aws/developertools/codebuild"
  name             = "codebuild-${var.environment}"
  description      = "Codebuild deployment for ${var.environment} environment"
  service_role     = "${var.codebuild_service_role_arn}"
  environment_type = "LINUX_CONTAINER"
  compute_type     = "BUILD_GENERAL1_SMALL"
  image            = "${var.codebuild_env_image}"
  buildspec        = "${var.buildspec_path}"
  privileged_mode  = false
  source_provider  = "CODECOMMIT"
  repository_url   = "https://github.com/mattyait/devops_terraform.git"

  environment_variables = [{
    name  = "ENVIRONMENT"
    value = "${var.environment}"
    },
    {
      name  = "ENV_VALUE_KEYNAME"
      value = "somevalue"
    },
  ]

  tags = {
    Name        = "codebuild-${var.environment}"
    Environment = "${var.environment}"
    Created_By  = "${var.created_by}"
  }
}
