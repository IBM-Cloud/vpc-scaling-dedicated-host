resource "ibm_is_security_group" "frontend_autoscale_sg" {
  name           = "${var.basename}-frontend-sg"
  vpc            = var.vpc_id
  resource_group = var.resource_group_id
}

resource "ibm_is_security_group" "backend_autoscale_sg" {
  name           = "${var.basename}-backend-sg"
  vpc            = var.vpc_id
  resource_group = var.resource_group_id
}

resource "ibm_is_security_group_rule" "lb_public_sg_rule_tcp_80" {
  group     = var.lb_public_sg_id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "lb_public_sg_rule_tcp_443" {
  group     = var.lb_public_sg_id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 443
    port_max = 443
  }
}

resource "ibm_is_security_group_rule" "lb_public_sg_rule_icmp" {
  group     = var.lb_public_sg_id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  icmp {
    type = 8
  }
}

resource "ibm_is_security_group_rule" "lb_public_sg_rule_tcp_outbound_80" {
  group     = var.lb_public_sg_id
  direction = "outbound"
  remote    = ibm_is_security_group.frontend_autoscale_sg.id
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "lb_public_sg_rule_tcp_outbound_443" {
  group     = var.lb_public_sg_id
  direction = "outbound"
  remote    = ibm_is_security_group.frontend_autoscale_sg.id
  tcp {
    port_min = 443
    port_max = 443
  }
}


resource "ibm_is_security_group_rule" "frontend_autoscale_sg_rule_tcp_80" {
  group     = ibm_is_security_group.frontend_autoscale_sg.id
  direction = "inbound"
  remote    = var.lb_public_sg_id
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "frontend_autoscale_sg_rule_tcp_443" {
  group     = ibm_is_security_group.frontend_autoscale_sg.id
  direction = "inbound"
  remote    = var.lb_public_sg_id
  tcp {
    port_min = 443
    port_max = 443
  }
}

resource "ibm_is_security_group_rule" "frontend_autoscale_sg_rule_backend_outbound" {
  group     = ibm_is_security_group.frontend_autoscale_sg.id
  direction = "outbound"
  remote    = var.lb_private_sg_id
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "frontend_autoscale_sg_rule_tcp_outbound" {
  group     = ibm_is_security_group.frontend_autoscale_sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 53
    port_max = 53
  }
}

resource "ibm_is_security_group_rule" "frontend_autoscale_sg_rule_udp_outbound" {
  group     = ibm_is_security_group.frontend_autoscale_sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  udp {
    port_min = 53
    port_max = 53
  }
}

resource "ibm_is_security_group_rule" "frontend_autoscale_sg_rule_tcp_80_outbound" {
  group     = ibm_is_security_group.frontend_autoscale_sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "frontend_autoscale_sg_rule_tcp_443_outbound" {
  group     = ibm_is_security_group.frontend_autoscale_sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 443
    port_max = 443
  }
}


resource "ibm_is_security_group_rule" "lb_private_sg_rule_tcp_inbound" {
  group     = var.lb_private_sg_id
  direction = "inbound"
  remote    = ibm_is_security_group.frontend_autoscale_sg.id
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "lb_private_sg_rule_tcp_outbound" {
  group     = var.lb_private_sg_id
  direction = "outbound"
  remote    = ibm_is_security_group.backend_autoscale_sg.id
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "backend_ingress_tcp_port_lb_private" {
  group     = ibm_is_security_group.backend_autoscale_sg.id
  direction = "inbound"
  remote    = var.lb_private_sg_id

  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "backend_autoscale_sg_rule_tcp_outbound" {
  group     = ibm_is_security_group.backend_autoscale_sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 53
    port_max = 53
  }
}

resource "ibm_is_security_group_rule" "backend_autoscale_sg_rule_udp_outbound" {
  group     = ibm_is_security_group.backend_autoscale_sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  udp {
    port_min = 53
    port_max = 53
  }
}

resource "ibm_is_security_group_rule" "backend_autoscale_sg_rule_tcp_80_outbound" {
  group     = ibm_is_security_group.backend_autoscale_sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "backend_autoscale_sg_rule_tcp_443_outbound" {
  group     = ibm_is_security_group.backend_autoscale_sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 443
    port_max = 443
  }
}

resource "ibm_is_security_group_rule" "backend_autoscale_sg_rule_tcp_pg_outbound" {
  group     = ibm_is_security_group.backend_autoscale_sg.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = var.postgresql_port
    port_max = var.postgresql_port
  }
}