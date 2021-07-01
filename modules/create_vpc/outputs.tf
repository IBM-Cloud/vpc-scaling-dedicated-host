output "load_balancer_public" {
  value = module.load_balancer_public.lb_hostname
}

# output "generated_ssh_key" {
#   value     = tls_private_key.ssh
#   sensitive = true
# }

