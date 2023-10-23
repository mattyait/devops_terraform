resource "aws_efs_file_system" "default" {
  count                           = var.enable ? 1 : 0
  encrypted                       = var.encrypted
  kms_key_id                      = var.kms_key_id
  performance_mode                = var.performance_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
  throughput_mode                 = var.throughput_mode

  dynamic "lifecycle_policy" {
    for_each = var.transition_to_ia == "" ? [] : [1]
    content {
      transition_to_ia = var.transition_to_ia
    }
  }
  tags = merge(var.tags, map("Name", var.name))
}

resource "aws_efs_mount_target" "mount_with_ip" {
  count           = var.enable && length(var.mount_target_subnets) > 0 && length(var.mount_target_ip_address) > 0 ? length(var.mount_target_subnets) : 0
  file_system_id  = join("", aws_efs_file_system.default.*.id)
  security_groups = var.security_groups
  ip_address      = var.mount_target_ip_address
  subnet_id       = var.mount_target_subnets[count.index]
}

resource "aws_efs_mount_target" "mount" {
  count           = var.enable && length(var.mount_target_subnets) > 0 ? length(var.mount_target_subnets) : 0
  file_system_id  = join("", aws_efs_file_system.default.*.id)
  security_groups = var.security_groups
  subnet_id       = var.mount_target_subnets[count.index]
}

data "template_file" "efs_file_system_policy" {
  count    = var.enable && length(var.policy_file_path) > 0 ? 1 : 0
  template = var.policy_file_path
  vars = {
    aws_efs_file_system_arn = aws_efs_file_system.default[0].arn
  }
}

resource "aws_efs_file_system_policy" "policy" {
  count          = var.enable && length(var.policy_file_path) > 0 ? 1 : 0
  file_system_id = join("", aws_efs_file_system.default.*.id)
  policy         = data.template_file.efs_file_system_policy[0].rendered
}