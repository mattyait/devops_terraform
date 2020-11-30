# Splitting and joining, and then compacting a list to get a normalised list
locals {
  name_list = compact(
    concat(
      split(
        var.split_delimiter,
        join(var.split_delimiter, aws_ssm_parameter.default.*.name,aws_ssm_parameter.default_with_lifecycle.*.name)
      ),
      split(
        var.split_delimiter,
        join(var.split_delimiter, data.aws_ssm_parameter.read.*.name)
      )
    )
  )

  value_list = compact(
    concat(
      split(
        var.split_delimiter,
        join(var.split_delimiter, aws_ssm_parameter.default.*.value, aws_ssm_parameter.default_with_lifecycle.*.value)
      ),
      split(
        var.split_delimiter,
        join(var.split_delimiter, data.aws_ssm_parameter.read.*.value)
      )
    )
  )

  arn_list = compact(
    concat(
      split(
        var.split_delimiter,
        join(var.split_delimiter, aws_ssm_parameter.default.*.arn, aws_ssm_parameter.default_with_lifecycle.*.arn)
      ),
      split(
        var.split_delimiter,
        join(var.split_delimiter, data.aws_ssm_parameter.read.*.arn)
      )
    )
  )
}

output "names" {
  value       = local.name_list
  description = "A list of all of the parameter names"
}

output "values" {
  description = "A list of all of the parameter values"
  value       = local.value_list
}

output "map" {
  description = "A map of the names and values created"
  value       = zipmap(local.name_list, local.value_list)
}

output "arn_map" {
  description = "A map of the names and ARNs created"
  value       = zipmap(local.name_list, local.arn_list)
}