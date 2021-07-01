variable "vpc_id" {
  type = string
}

variable "resource_group_id" {
  type = string

}

variable "lb_name" {
  type = string
}
variable "lb_type" {
  type    = string
  default = ""
}

variable "subnets" {
  type = list(string)
}

variable "http_port" {
  type    = number
  default = 80
}

variable "tags" {
  type    = list(string)
  default = ["terraform", "vpc-scaling"]
}

variable "health_monitor_url" {}