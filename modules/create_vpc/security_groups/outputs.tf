
output "frontend_sg_id" {
  value = ibm_is_security_group.frontend_autoscale_sg.id
}

output "backend_sg_id" {
  value = ibm_is_security_group.backend_autoscale_sg.id
}