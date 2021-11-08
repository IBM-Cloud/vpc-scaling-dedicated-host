###########################################
# Account: Resource group creation...
###########################################
resource "ibm_resource_group" "group" {
  count = var.resource_group_name != "" ? 0 : 1
  name  = "${var.basename}-group"
  tags  = var.tags
}

data "ibm_resource_group" "group" {
  count = var.resource_group_name != "" ? 1 : 0
  name  = var.resource_group_name
}

locals {
  resource_group_id   = var.resource_group_name != "" ? data.ibm_resource_group.group.0.id : ibm_resource_group.group.0.id
  resource_group_name = var.resource_group_name != "" ? data.ibm_resource_group.group.0.name : ibm_resource_group.group.0.name
}

###########################################
# Step 1: Provision Cloud services...
###########################################

module "create_services" {
  count             = var.step1_create_services ? 1 : 0
  source            = "./modules/create_services"
  basename          = var.basename
  region            = var.region
  resource_group_id = local.resource_group_id
  tags              = var.tags
  create_logging    = var.step1_create_logging
  create_monitoring = var.step1_create_monitoring

}

#############################################################################
#Step 2: Create a VPC and its resources...
#############################################################################


module "create_vpc" {
  count               = var.step2_create_vpc ? 1 : 0
  source              = "./modules/create_vpc"
  basename            = var.basename
  region              = var.region
  resource_group_id   = local.resource_group_id
  resource_group_name = local.resource_group_name
  image_name          = var.image_name
  ssh_keyname         = var.ssh_keyname
  is_dynamic          = var.step3_is_dynamic
  instance_count      = var.step3_instance_count
  postgresql_key      = module.create_services.0.postgresql_key
  postgresql_crn      = module.create_services.0.postgresql_crn
  cos_key             = module.create_services.0.cos_key
  bucket_name         = module.create_services.0.bucket_name
  is_scheduled        = var.step3_is_scheduled
  depends_on          = [module.create_services]
}

#############################################################################
#Step 3: Create a dedicated host group, host and an instance with encrypted volume...
#############################################################################

module "create_dedicated" {
  count                     = var.step4_create_dedicated ? 1 : 0
  source                    = "./modules/create_dedicated"
  basename                  = var.basename
  resource_group_id         = local.resource_group_id
  region                    = var.region
  resource_group_name       = local.resource_group_name
  image_name                = var.image_name
  ssh_keyname_dedicated     = var.ssh_keyname_dedicated
  tags                      = concat(var.tags, ["dedicated"])
  keyprotect_guid           = module.create_services.0.keyprotect_guid
  keyprotect_key_type       = module.create_services.0.keyprotect_key_type
  keyprotect_key_id         = module.create_services.0.keyprotect_key_id
  resize_dedicated_instance = var.step5_resize_dedicated_instance
  postgresql_key            = module.create_services.0.postgresql_key
  postgresql_crn            = module.create_services.0.postgresql_crn
  cos_key                   = module.create_services.0.cos_key
  bucket_name               = module.create_services.0.bucket_name
  resize_dedicated_instance_volume = var.step5_resize_dedicated_instance_volume
}


