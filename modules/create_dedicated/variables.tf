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

variable "ssh_keyname_dedicated" {
  type = string
}

variable "tags" {
  type = list(string)
}

variable "keyprotect_guid" {
  type = string
}

variable "keyprotect_key_type" {
  type = string
}

variable "keyprotect_key_id" {
  type = string
}

variable "keyprotect_crn" {
  type = string
}

variable "resize_dedicated_instance_volume" {
  type = bool
}

variable "resize_dedicated_instance" {
  type = bool
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
