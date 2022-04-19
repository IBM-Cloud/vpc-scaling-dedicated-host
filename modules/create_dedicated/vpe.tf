module "vpe_cloud_services" {
  source            = "../create_vpe"
  vpc_id            = ibm_is_vpc.dedicated_vpc.id
  resource_group_id = var.resource_group_id
  security_groups   = [ibm_is_security_group.dedicated_security_group.id]
  subnets           = ibm_is_subnet.dedicated_subnet
  endpoints         = local.endpoints
  basename          = var.basename
  region            = var.region
  tags              = var.tags
}


locals {
  endpoints = [
    {
      name     = "postgresql",
      crn      = var.postgresql_crn
    },
    {
      name     = "cos",
      crn      = "crn:v1:bluemix:public:cloud-object-storage:global:::endpoint:s3.direct.${var.region}.cloud-object-storage.appdomain.cloud"
    },
    {
      name     = "kms",
      crn      = "crn:v1:bluemix:public:kms:${var.region}:::endpoint:private.${var.region}.kms.cloud.ibm.com"
    }
  ]
}
