/*resource "ibm_is_vpc_address_prefix" "subnet_prefix" {
  count = 2
  name  = "${var.subnet_name}-prefix-zone-${count.index + 1}"
  zone  = "${var.region}-${(count.index % 2) + 1}"
  vpc   = var.vpc_id
  cidr  = var.cidr_blocks[count.index]
}*/

resource "ibm_is_subnet" "subnets" {
  count                    = 2
  name                     = "${var.subnet_name}-${count.index + 1}"
  vpc                      = var.vpc_id
  zone                     = "${var.region}-${count.index + 1}"
  resource_group           = var.resource_group_id
  total_ipv4_address_count = "256"
  #ipv4_cidr_block = ibm_is_vpc_address_prefix.subnet_prefix[count.index].cidr
  public_gateway  = (var.public_gateways[count.index].zone == "${var.region}-${count.index + 1}") ? var.public_gateways[count.index].id : var.public_gateways[count.index+1].id
}