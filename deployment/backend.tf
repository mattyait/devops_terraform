terraform {
  backend "s3" {}
  required_version = ">= 0.12"
  required_providers {
    local    = "~> 1.3"
    null     = "~> 2.1"
    template = "~> 2.1"
  }
}