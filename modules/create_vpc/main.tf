data "ibm_is_image" "image" {
  name = var.image_name
}

# a ssh key
data "ibm_is_ssh_key" "sshkey" {
  count = var.ssh_keyname != "" ? 1 : 0
  name  = var.ssh_keyname
}


locals {
  ssh_key_ids = var.ssh_keyname != "" ? [data.ibm_is_ssh_key.sshkey[0].id] : []
}

resource "ibm_is_vpc" "vpc" {
  name           = "${var.basename}-vpc"
  resource_group = var.resource_group_id
}

resource "ibm_is_public_gateway" "gateway" {
  count          = 2
  name           = "${var.basename}-gateway-${count.index + 1}"
  vpc            = ibm_is_vpc.vpc.id
  zone           = "${var.region}-${count.index + 1}"
  resource_group = var.resource_group_id
}

module "subnets_frontend" {

  source            = "./subnets"
  subnet_name       = "${var.basename}-subnet-frontend"
  vpc_id            = ibm_is_vpc.vpc.id
  resource_group_id = var.resource_group_id
  region            = var.region
  cidr_blocks       = ["10.241/24", "10.241.64/24"]
  public_gateways   = ibm_is_public_gateway.gateway
}


module "load_balancer_public" {

  source             = "./lb"
  vpc_id             = ibm_is_vpc.vpc.id
  resource_group_id  = var.resource_group_id
  lb_name            = "${var.basename}-lb-public"
  lb_type            = "public"
  subnets            = module.subnets_frontend.subnets_ids
  http_port          = 80
  health_monitor_url = "/health"
}

module "subnets_backend" {

  source            = "./subnets"
  subnet_name       = "${var.basename}-subnet-backend"
  vpc_id            = ibm_is_vpc.vpc.id
  resource_group_id = var.resource_group_id
  region            = var.region
  cidr_blocks       = ["10.241.1/24", "10.241.65/24"]
  public_gateways   = ibm_is_public_gateway.gateway
}

module "load_balancer_private" {

  source             = "./lb"
  vpc_id             = ibm_is_vpc.vpc.id
  resource_group_id  = var.resource_group_id
  lb_name            = "${var.basename}-lb-private"
  lb_type            = "private"
  subnets            = module.subnets_backend.subnets_ids
  http_port          = 80
  health_monitor_url = "/health"
}

module "security_groups" {

  source            = "./security_groups"
  basename          = var.basename
  vpc_id            = ibm_is_vpc.vpc.id
  resource_group_id = var.resource_group_id
  lb_public_sg_id   = module.load_balancer_public.lb_sg_id
  lb_private_sg_id  = module.load_balancer_private.lb_sg_id
  postgresql_port   = var.postgresql_key.credentials["connection.postgres.hosts.0.port"]

  depends_on = [
    module.load_balancer_public,
    module.load_balancer_private
  ]
}

module "autoscale_frontend" {
  source            = "./autoscale"
  vpc_id            = ibm_is_vpc.vpc.id
  resource_group_id = var.resource_group_id
  subnet_id         = module.subnets_frontend.subnet_id
  subnets           = module.subnets_frontend.subnets_ids
  region            = var.region
  image_id          = data.ibm_is_image.image.id
  ssh_key_ids       = local.ssh_key_ids
  security_groups   = [module.security_groups.frontend_sg_id]
  name              = "${var.basename}-frontend"
  lb_id             = module.load_balancer_public.lb_id
  lb_pool_id        = module.load_balancer_public.lb_pool_id
  is_dynamic        = var.is_dynamic
  instance_count    = var.instance_count
  is_scheduled      = var.is_scheduled 

  user_data = templatefile("${path.module}/../../scripts/cloud-init-frontend.yaml", {
    app_deploy = base64encode(templatefile("${path.module}/../../scripts/app-deploy-frontend.sh", {
      lb_hostname_public  = module.load_balancer_public.lb_hostname
      lb_hostname_private = module.load_balancer_private.lb_hostname
      app_url             = "https://github.com/IBM-Cloud/vpc-tutorials.git"
      app_repo            = "vpc-tutorials"
      app_directory       = "sampleapps/php-webapp"
    }))
  })

  depends_on = [
    module.load_balancer_private,
    module.load_balancer_public,
    module.security_groups
  ]
}

module "autoscale_backend" {
  source            = "./autoscale"
  vpc_id            = ibm_is_vpc.vpc.id
  resource_group_id = var.resource_group_id
  subnet_id         = module.subnets_backend.subnet_id
  subnets           = module.subnets_backend.subnets_ids
  region            = var.region
  image_id          = data.ibm_is_image.image.id
  ssh_key_ids       = local.ssh_key_ids
  security_groups   = [module.security_groups.backend_sg_id]
  name              = "${var.basename}-backend"
  lb_id             = module.load_balancer_private.lb_id
  lb_pool_id        = module.load_balancer_private.lb_pool_id
  is_dynamic        = var.is_dynamic
  instance_count    = var.instance_count
  is_scheduled      = var.is_scheduled 

  user_data = templatefile("${path.module}/../../scripts/cloud-init-backend.yaml", {
    pg_credentials  = base64encode("[${jsonencode(var.postgresql_key)}]")

    cos_credentials = base64encode("[${jsonencode(var.cos_key)}]")

    app_deploy = base64encode(templatefile("${path.module}/../../scripts/app-deploy-backend.sh", {
      app_url       = "https://github.com/IBM-Cloud/vpc-tutorials.git"
      app_repo      = "vpc-tutorials"
      app_directory = "sampleapps/nodejs-graphql"
      bucket_name   = var.bucket_name
      region        = var.region
      update        = "false"
    }))
  })

  depends_on = [
    module.load_balancer_private,
    module.security_groups
  ]
}