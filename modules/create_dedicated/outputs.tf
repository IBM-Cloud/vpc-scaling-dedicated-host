 output "ip_address_dedicated_instance" {
    value = ibm_is_floating_ip.instance_floating_ip.address
}