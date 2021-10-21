resource "ibm_is_vpc" "dedicated_vpc" {
  name           = "${var.basename}-dedicated-vpc"
  resource_group = var.resource_group_id
}

resource "ibm_is_subnet" "dedicated_subnet" {
  count           = 1
  name            = "${var.basename}-dedicated-subnet"
  vpc             = ibm_is_vpc.dedicated_vpc.id
  zone            = "${var.region}-1"
  total_ipv4_address_count = 256
  resource_group = var.resource_group_id
}

data "ibm_is_image" "image" {
  name = var.image_name
}

# a ssh key
data "ibm_is_ssh_key" "sshkey" {
  count = var.ssh_keyname_dedicated != "" ? 1 : 0
  name  = var.ssh_keyname_dedicated
}

locals {
  ssh_key_ids = var.ssh_keyname_dedicated != "" ? [data.ibm_is_ssh_key.sshkey[0].id] : []
}


resource "ibm_is_dedicated_host_group" "dedicated_host_group" {
  class          = "cx2"
  family         = "compute"
  zone           = "${var.region}-1"
  name           = "${var.basename}-dh-group"
  resource_group = var.resource_group_id
}

resource "ibm_is_dedicated_host" "dedicated_host" {
  profile    = "cx2-host-152x304"
  host_group = ibm_is_dedicated_host_group.dedicated_host_group.id
  name       = "${var.basename}-dh"
}

resource "ibm_is_security_group" "dedicated_security_group" {
  name = "${var.basename}-dedicated-sg"
  vpc  = ibm_is_vpc.dedicated_vpc.id
}

resource "ibm_is_security_group_rule" "dedicated_security_group_rule_tcp_80" {
  group      = ibm_is_security_group.dedicated_security_group.id
  direction  = "inbound"
  remote     = "0.0.0.0/0"
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "dedicated_security_group_rule_tcp_443" {
  group      = ibm_is_security_group.dedicated_security_group.id
  direction  = "inbound"
  remote     = "0.0.0.0/0"
  tcp {
    port_min = 443
    port_max = 443
  }
}


resource "ibm_is_security_group_rule" "dedicated_security_group_rule_tcp_outbound_443" {
  group     = ibm_is_security_group.dedicated_security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 443
    port_max = 443
  }
}


resource "ibm_is_security_group_rule" "dedicated_security_group_rule_tcp_outbound_80" {
  group     = ibm_is_security_group.dedicated_security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "dedicated_security_group_rule_tcp_outbound_53" {
  group     = ibm_is_security_group.dedicated_security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 53
    port_max = 53
  }
}

resource "ibm_is_security_group_rule" "dedicated_security_group_rule_udp_outbound_53" {
  group     = ibm_is_security_group.dedicated_security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  udp {
    port_min = 53
    port_max = 53
  }
}

resource "ibm_is_security_group_rule" "dedicated_security_group_rule_tcp_pg_outbound" {
  group     = ibm_is_security_group.dedicated_security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = var.postgresql_key.credentials["connection.postgres.hosts.0.port"]
    port_max = var.postgresql_key.credentials["connection.postgres.hosts.0.port"]
  }
}

resource "ibm_iam_authorization_policy" "dedicated_volume_policy" {
  source_service_name         = "server-protect"
  target_service_name         = var.keyprotect_key_type
  target_resource_instance_id = var.keyprotect_guid
  roles                       = ["Reader"]
}

resource "ibm_is_volume" "dedicated_volume" {
  name           = "${var.basename}-volume"
  profile        = "10iops-tier"
  zone           = "${var.region}-1"
  resource_group = var.resource_group_id
  capacity       = var.resize_dedicated_instance_volume ? 250 : 100
  encryption_key = var.keyprotect_key_id
  depends_on = [ibm_iam_authorization_policy.dedicated_volume_policy]
}


// Provision instance in a dedicated host
resource "ibm_is_instance" "dedicated_instance" {
  name    = "${var.basename}-dedicated-instance"
  image   = data.ibm_is_image.image.id
  profile = var.resize_dedicated_instance ? "cx2-8x16" : "cx2-2x4"

  primary_network_interface {
    subnet          = ibm_is_subnet.dedicated_subnet.0.id
    security_groups = [ibm_is_security_group.dedicated_security_group.id]
  }
  dedicated_host     = ibm_is_dedicated_host.dedicated_host.id
  vpc                = ibm_is_vpc.dedicated_vpc.id
  zone               = "${var.region}-1"
  keys               = local.ssh_key_ids
  resource_group     = var.resource_group_id
  volumes            = [ibm_is_volume.dedicated_volume.id]
  auto_delete_volume = true

  user_data = templatefile("${path.module}/../../scripts/cloud-init-backend.yaml", {
    pg_credentials  = base64encode("[${jsonencode(var.postgresql_key)}]")

    cos_credentials = base64encode("[${jsonencode(var.cos_key)}]")

    app_deploy = base64encode(templatefile("${path.module}/../../scripts/app-deploy-backend.sh", {
      app_url       = "https://github.com/IBM-Cloud/vpc-tutorials.git"
      app_repo      = "vpc-tutorials"
      app_directory = "sampleapps/nodejs-graphql"
      bucket_name   = var.bucket_name
      region        = var.region
      update        = "true"
    }))
  })

  //User can configure timeouts
  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

resource "ibm_is_floating_ip" "instance_floating_ip" {
  name   = "${var.basename}-dedicated-instance-ip"
  target = ibm_is_instance.dedicated_instance.primary_network_interface[0].id
  resource_group = var.resource_group_id
}