variable "vpc_id" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "region" {
  type    = string
  default = "us-south"
}
variable "resource_group_id" {
  type = string
}
variable "cidr_blocks" {
  type = list(string)
}

variable "public_gateways" {
  type    = any
}