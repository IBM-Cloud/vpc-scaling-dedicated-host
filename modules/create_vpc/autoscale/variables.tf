variable "resource_group_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "region" {
  type    = string
  default = "us-south"
}

variable "image_id" {
  type = string

}

variable "instance_count" {
  type = number

}

variable "ssh_key_ids" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
}

variable "name" {
  type = string

}

variable "lb_id" {
  type = string
}

variable "lb_pool_id" {
  type = string
}

variable "is_dynamic" {
  type = bool
}

variable "is_scheduled" {
  type        = bool
  default     = false
  description = "Set this to true to enable scheduled scaling"
}

variable "user_data" {}