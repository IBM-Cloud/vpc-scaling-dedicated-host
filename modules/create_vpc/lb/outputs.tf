output "lb_id" {
  value = ibm_is_lb.lb.id
}

output "lb_pool_id" {
  value = ibm_is_lb_pool.lb-pool.id
}

output "lb_sg_id" {
  value = ibm_is_security_group.lb_sg.id
}

output "lb_hostname" {
  value = ibm_is_lb.lb.hostname
}