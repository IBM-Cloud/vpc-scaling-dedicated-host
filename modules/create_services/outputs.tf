output "keyprotect_guid" {
  value = ibm_resource_instance.keyprotect.guid
}

output "keyprotect_key_type" {
  value = ibm_kms_key.key.type
}

output "keyprotect_key_id" {
  value = ibm_kms_key.key.id
}

output "keyprotect_crn" {
  value = ibm_kms_key.key.crn
}

output "cos_crn" {
  value = ibm_resource_instance.cos.resource_crn
}

output "cos_key" {
  value     = ibm_resource_key.cos_key
  sensitive = true
}

output "postgresql" {
  value      = ibm_database.postgresql
  sensitive  = true
  depends_on = [time_sleep.wait_for_postgresql_initialization]
}

output "postgresql_crn" {
  value      = ibm_database.postgresql.id
  depends_on = [time_sleep.wait_for_postgresql_initialization]
}

output "postgresql_key" {
  value      = ibm_resource_key.postgresql_key
  sensitive  = true
  depends_on = [time_sleep.wait_for_postgresql_initialization]
}

output "bucket_name" {
  value = ibm_cos_bucket.bucket.bucket_name
}
