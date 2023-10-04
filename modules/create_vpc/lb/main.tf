resource "ibm_is_security_group" "lb_sg" {
  name           = "${var.lb_name}-sg"
  vpc            = var.vpc_id
  resource_group = var.resource_group_id
}

resource "ibm_is_lb" "lb" {
  name            = "${var.lb_name}-lb"
  subnets         = var.subnets
  resource_group  = var.resource_group_id
  type            = var.lb_type
  tags            = var.tags
  security_groups = [ibm_is_security_group.lb_sg.id]
  logging         = true
}

resource "ibm_is_lb_pool" "lb-pool" {
  lb                 = ibm_is_lb.lb.id
  name               = "${var.lb_name}-lb-pool"
  protocol           = "http"
  algorithm          = "round_robin"
  health_delay       = "15"
  health_retries     = "2"
  health_timeout     = "5"
  health_type        = "http"
  health_monitor_url = var.health_monitor_url
}

resource "ibm_is_lb_listener" "lb-listener" {
  lb           = ibm_is_lb.lb.id
  port         = var.http_port
  protocol     = "http"
  default_pool = element(split("/", ibm_is_lb_pool.lb-pool.id), 1)
}
