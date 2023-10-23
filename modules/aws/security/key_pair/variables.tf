variable "name" {
  description = "Unique name for the key, should also be a valid filename. This will prefix the public/private key."
}

variable "path" {
  description = "Path to a directory where the public and private key will be stored."
  default     = ""
}

variable "algorithm" {
  type        = string
  description = "Algorithm for Key pair creation"
  default     = "RSA"
}

variable "curve" {
  type        = string
  description = "The name of the elliptic curve to use. May be any one of P224, P256, P384 or P521, with P224 as the default., The size of the generated RSA key in bits. Defaults to 2048"
  default     = "2048"
}