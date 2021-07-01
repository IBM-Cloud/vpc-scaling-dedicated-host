output "resource_group_name" {
  value = local.resource_group_name
}

output "load_balancer_url" {
  value = var.step2_create_vpc ? module.create_vpc[0].load_balancer_public : null
}

output "ip_address_dedicated_instance" {
  value = var.step4_create_dedicated ? module.create_dedicated[0].ip_address_dedicated_instance : null
}