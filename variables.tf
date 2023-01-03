variable "region" {
  type        = string
  default     = "us-south"
  description = "The region(location) in which you would like to provision the resources."
}
variable "resource_group_name" {
  type        = string
  default     = ""
  description = "If not provided, a new resource group will be created."
}
variable "ibmcloud_timeout" {
  type        = number
  default     = 600
  description = "Timeout to provision all the resources."
}
variable "basename" {
  type        = string
  default     = "vpc-scaling"
  description = "An unique to differentiate the resources from other."
}
variable "tags" {
  type        = list(string)
  default     = ["terraform", "vpc-scaling"]
  description = "Tags to differentiate the provisioned resources."
}

variable "ssh_keyname" {
  type        = string
  default     = ""
  description = "Provide an existing SSH key in the resource group mentioned above."
}

variable "ssh_keyname_dedicated" {
  type        = string
  default     = ""
  description = "Provide an existing SSH key in the resource group mentioned above."
}

variable "image_name" {
  type        = string
  default     = "ibm-ubuntu-22-04-1-minimal-amd64-3"
  description = "For other Ubuntu image names, run ibmcloud is images command."
}

variable "step1_create_services" {
  type        = bool
  default     = false
  description = "Set this to true to create the cloud services."
}

variable "step1_create_logging" {
  type        = bool
  default     = false
  description = "Create a logging instance in the region and resource group provided above"
}

variable "step1_create_monitoring" {
  type        = bool
  default     = false
  description = "Create a monitoring instance in the region and resource group provided above"
}

variable "step2_create_vpc" {
  type        = bool
  default     = false
  description = "Set this to true to create a VPC and other resources for autoscaling."
}

variable "step3_instance_count" {
  type        = number
  default     = 1
  description = "The minimum number of instances to be provisioned."
}

variable "step3_is_dynamic" {
  type        = bool
  default     = false
  description = "Set this to true to enable dynamic autoscaling based on the metrics."
}

variable "step3_is_scheduled" {
  type        = bool
  default     = false
  description = "Set this to true to enable scheduled scaling"
}

variable "step4_create_dedicated" {
  type        = bool
  default     = false
  description = "Set this to true to create a dedicated host."
}

variable "step5_resize_dedicated_instance" {
  type        = bool
  default     = false
  description = "Resize the dedicated instance to a new profile"
}

variable "step5_resize_dedicated_instance_volume" {
  type        = bool
  default     = false
  description = "Resize the data volume attached to an instance in a dedicated host."
}
