output "subnets_ids" {
  value = ibm_is_subnet.subnets.*.id 
}

output "subnet_id" {
  value = ibm_is_subnet.subnets.0.id
}

output "subnets" {
  value = ibm_is_subnet.subnets
}