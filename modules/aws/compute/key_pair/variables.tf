variable "name" {
  description = "Unique name for the key, should also be a valid filename. This will prefix the public/private key."
}

variable "path" {
  description = "Path to a directory where the public and private key will be stored."
  default     = ""
}

variable "enable" {
  description = "Variable to toggle on/off this part, default is always true"
  default     = "true"
}
