variable enable {
  default = "true"
}

variable target_group_name {}

variable port {
  default = "80"
}

variable protocol {
  default = "HTTP"
}

variable vpc_id {}
variable environment {}
variable description {}

variable deregistration_delay {
  default = "300"
}
