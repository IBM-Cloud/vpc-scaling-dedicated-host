variable "basename" {
  type = string
}
variable "vpc_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-south"
}
variable "resource_group_id" {
  type = string
}

variable "lb_public_sg_id" {
  type    = string
  default = ""
}

variable "lb_private_sg_id" {
  type    = string
  default = ""
}

variable "postgresql_port" {
  default = 31775
}