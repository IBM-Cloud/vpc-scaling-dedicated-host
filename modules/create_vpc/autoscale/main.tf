resource "ibm_is_instance_template" "instance_template" {
  name           = "${var.name}-template"
  image          = var.image_id
  profile        = "cx2-2x4"
  resource_group = var.resource_group_id

  boot_volume {
    encryption                       = var.keyprotect_crn
    delete_volume_on_instance_delete = true
  }

  primary_network_interface {
    subnet          = var.subnet_id
    security_groups = var.security_groups
  }

  vpc       = var.vpc_id
  zone      = "${var.region}-1"
  keys      = var.ssh_key_ids
  user_data = var.user_data

  lifecycle {
    create_before_destroy = true
  }
  /*
  Optionally add volume attachments if needed for your application
  volume_attachments {
    delete_volume_on_instance_delete = true
    name                             = "${var.name}-template-volume-attachment"
    volume_prototype {
      profile  = "general-purpose"
      capacity = 200
    }
  }
  */
}

resource "ibm_is_instance_group" "instance_group" {
  name               = "${var.name}-group"
  instance_template  = ibm_is_instance_template.instance_template.id
  instance_count     = var.instance_count
  subnets            = var.subnets
  load_balancer      = var.lb_id
  load_balancer_pool = element(split("/", var.lb_pool_id), 1)
  application_port   = 80
  resource_group     = var.resource_group_id
  timeouts {
    create = "20m"
    delete = "15m"
    update = "10m"
  }
}

resource "ibm_is_instance_group_manager" "autoscale_instance_group_manager" {
  count                = var.is_dynamic ? 1 : 0
  name                 = "${var.name}-autoscale-manager"
  aggregation_window   = 90
  instance_group       = ibm_is_instance_group.instance_group.id
  cooldown             = 120
  manager_type         = "autoscale"
  enable_manager       = true
  max_membership_count = 5
}

resource "ibm_is_instance_group_manager_policy" "cpuPolicy" {
  count                  = var.is_dynamic ? 1 : 0
  instance_group         = ibm_is_instance_group.instance_group.id
  instance_group_manager = ibm_is_instance_group_manager.autoscale_instance_group_manager.0.manager_id
  metric_type            = "cpu"
  metric_value           = 10
  policy_type            = "target"
  name                   = "${var.name}-instance-group-manager-policy"
}

resource "ibm_is_instance_group_manager" "schedule_instance_group_manager" {
  count          = var.is_scheduled ? 1 : 0
  name           = "${var.name}-schedule-manager"
  instance_group = ibm_is_instance_group.instance_group.id
  manager_type   = "scheduled"
  enable_manager = true
}

resource "ibm_is_instance_group_manager_action" "instance_group_manager_action" {
  count                  = var.is_scheduled ? 1 : 0
  name                   = "${var.name}-schedule-manager-action"
  instance_group         = ibm_is_instance_group.instance_group.id
  instance_group_manager = ibm_is_instance_group_manager.schedule_instance_group_manager.0.manager_id
  run_at                 = timeadd(timestamp(), "5m")
  target_manager         = ibm_is_instance_group_manager.autoscale_instance_group_manager.0.manager_id
  min_membership_count   = 2
  max_membership_count   = 5
}
