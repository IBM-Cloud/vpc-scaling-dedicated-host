variable "basename" {
  type = string
}

variable "region" {
  type    = string
  default = "us-south"
}

variable "resource_group_id" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "image_name" {
  type = string
}

variable "instance_count" {
  type = number
}


variable "ssh_keyname" {
  type = string
}

variable "tags" {
  type    = list(string)
  default = ["terraform", "vpc-scaling"]
}

variable "is_dynamic" {
  type    = bool
  default = false
}

variable "is_scheduled" {
  type    = bool
  default = false
}

variable "cos_key" {
  type = any
}

variable "postgresql_crn" {
  type = string
}

variable "postgresql_key" {
  type = any
}

variable "bucket_name" {
  type = string
}