data "aws_ssm_parameter" "read" {
  count = var.enabled ? length(var.parameter_read) : 0
  name  = element(var.parameter_read, count.index)
}

resource "aws_ssm_parameter" "default" {
  count = var.enabled && var.ignore_value_changes == false ? length(var.parameter_write) : 0
  name  = tolist(var.parameter_write)[count.index]["name"]

  description = lookup(
    tolist(var.parameter_write)[count.index],
    "description",
    tolist(var.parameter_write)[count.index]["name"]
  )

  type            = lookup(tolist(var.parameter_write)[count.index], "type", "SecureString")
  tier            = lookup(var.parameter_write[count.index], "tier", "Standard")
  key_id          = lookup(tolist(var.parameter_write)[count.index], "type", "SecureString") == "SecureString" && length(var.kms_arn) > 0 ? var.kms_arn : ""
  value           = tolist(var.parameter_write)[count.index]["value"]
  overwrite       = lookup(tolist(var.parameter_write)[count.index], "overwrite", "false")
  allowed_pattern = lookup(tolist(var.parameter_write)[count.index], "allowed_pattern", "")
  tags            = var.tags
}


resource "aws_ssm_parameter" "default_with_lifecycle" {
  count = var.enabled && var.ignore_value_changes ? length(var.parameter_write) : 0
  name  = tolist(var.parameter_write)[count.index]["name"]

  description = lookup(
    tolist(var.parameter_write)[count.index],
    "description",
    tolist(var.parameter_write)[count.index]["name"]
  )

  type            = lookup(tolist(var.parameter_write)[count.index], "type", "SecureString")
  tier            = lookup(var.parameter_write[count.index], "tier", "Standard")
  key_id          = lookup(tolist(var.parameter_write)[count.index], "type", "SecureString") == "SecureString" && length(var.kms_arn) > 0 ? var.kms_arn : ""
  value           = tolist(var.parameter_write)[count.index]["value"]
  overwrite       = lookup(tolist(var.parameter_write)[count.index], "overwrite", "false")
  allowed_pattern = lookup(tolist(var.parameter_write)[count.index], "allowed_pattern", "")
  tags            = var.tags

  lifecycle {
    ignore_changes = [
      value,
      ]
  }
}