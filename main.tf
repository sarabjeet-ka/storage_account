locals {
  flattened_user_identities = flatten([
    for k, v in var.storage_account_variables : [
      for id in (v.user_identities != null ? v.user_identities : []) : {
        acr_key              = k
        identity_name        = id.name
        resource_group_name  = id.resource_group_name
      }
    ]
  ])

  user_identity_map = {
    for identity in local.flattened_user_identities : "${identity.acr_key}_${identity.identity_name}" => {
      name                = identity.identity_name
      resource_group_name = identity.resource_group_name
    }
  }

  user_identity_ids = {
    for k, v in var.storage_account_variables : k => [
      for id in (v.user_identities != null ? v.user_identities : []) : data.azurerm_user_assigned_identity.example["${k}_${id.identity_name}"].id
    ]
  }

  identity_configs = {
    for k, v in var.storage_account_variables : k => {
      type = v.use_system_assigned_identity && v.use_user_assigned_identity ? "SystemAssigned, UserAssigned" :v.use_system_assigned_identity ? "SystemAssigned" : v.use_user_assigned_identity ? "UserAssigned" : ""
      identity_ids = v.use_user_assigned_identity ? local.user_identity_ids[k] : []
    }
  }
}

data "azurerm_user_assigned_identity" "example" {
  for_each = local.user_identity_map
  name     = each.value.name
  resource_group_name = each.value.resource_group_name
}


resource "azurerm_storage_account" "storage_account" {
  for_each                          = var.storage_account_variables
  name                              = each.value.storage_account_name
  resource_group_name               = each.value.storage_account_resource_group_name
  location                          = each.value.storage_account_location
  account_kind                      = each.value.account_kind
  account_tier                      = each.value.account_tier
  account_replication_type          = each.value.account_replication_type
  cross_tenant_replication_enabled  = each.value.cross_tenant_replication_enabled
  access_tier                       = each.value.access_tier
  edge_zone                         = each.value.edge_zone
 https_traffic_only_enabled =        each.value.https_traffic_only_enabled
  min_tls_version                   = each.value.min_tls_version
  allow_nested_items_to_be_public   = each.value.allow_nested_items_to_be_public
  shared_access_key_enabled         = each.value.shared_access_key_enabled
  public_network_access_enabled     = each.value.public_network_access_enabled
  default_to_oauth_authentication   = each.value.default_to_oauth_authentication
  is_hns_enabled                    = (each.value.account_tier == "Standard" || (each.value.account_tier == "Premium" && each.value.account_kind == "BlockBlobStorage") )? each.value.is_hns_enabled : false
  nfsv3_enabled                     = ( ( (each.value.account_tier == "Standard" && each.value.account_kind == "StorageV2") || (each.value.account_tier == "Premium" && each.value.account_kind == "BlockBlobStorage") ) && each.value.is_hns_enabled == true && (each.value.account_replication_type == "LRS" || each.value.account_replication_type == "RAGRS") ) ? each.value.nfsv3_enabled : false
  large_file_share_enabled          = each.value.large_file_share_enabled
 queue_encryption_key_type = ( each.value.account_kind == "Storage" && each.value.queue_encryption_key_type == "Account" ) ? "Service" : each.value.queue_encryption_key_type 
 table_encryption_key_type = ( each.value.account_kind == "Storage" && each.value.table_encryption_key_type == "Account" ) ? "Service" : each.value.table_encryption_key_type
  infrastructure_encryption_enabled = ( each.value.account_kind == "StorageV2" || (each.value.account_tier == "Premium" && (each.value.account_kind == "BlockBlobStorage" || each.value.account_kind == "FileStorage")) ) ? each.value.infrastructure_encryption_enabled : false
  sftp_enabled                      =( each.value.is_hns_enabled == true ) ? each.value.sftp_enabled : false

dynamic "queue_properties" {
  for_each = (each.value.account_tier == "Standard" && 
              (each.value.account_kind == "Storage" || each.value.account_kind == "StorageV2") && 
              each.value.queue_properties != null) ? [1] : []
  content {
      cors_rule {
      allowed_headers    = each.value.queue_properties.cors_rule.allowed_headers 
      allowed_methods    = each.value.queue_properties.cors_rule.allowed_methods 
      allowed_origins    = each.value.queue_properties.cors_rule.allowed_origins 
      exposed_headers    =each.value.queue_properties.cors_rule.exposed_headers
      max_age_in_seconds = each.value.queue_properties.cors_rule.max_age_in_seconds
    }
    logging {
      delete                = each.value.queue_properties.logging.delete
      read                  = each.value.queue_properties.logging.read
      version               = each.value.queue_properties.logging.version
      write                 = each.value.queue_properties.logging.write
      retention_policy_days = each.value.queue_properties.logging.retention_policy_days
    }

    minute_metrics {
      enabled               = each.value.queue_properties.minute_metrics.enabled 
      version               = each.value.queue_properties.minute_metrics.version
      include_apis          = each.value.queue_properties.minute_metrics.include_apis
      retention_policy_days = each.value.queue_properties.minute_metrics.retention_policy_days
    }

    hour_metrics {
      enabled               = each.value.queue_properties.hour_metrics.enabled
      version               = each.value.queue_properties.hour_metrics.version
      include_apis          = each.value.queue_properties.hour_metrics.include_apis
      retention_policy_days = each.value.queue_properties.hour_metrics.retention_policy_days
    }
  }
}
 dynamic "blob_properties" {
for_each = each.value.blob_properties != null ? [1] : []
  content {
    versioning_enabled            = each.value.blob_properties.versioning_enabled
    change_feed_enabled           = each.value.blob_properties.change_feed_enabled
    change_feed_retention_in_days = each.value.blob_properties.change_feed_retention_in_days
    default_service_version       = each.value.blob_properties.default_service_version
    last_access_time_enabled      = each.value.blob_properties.last_access_time_enabled

    cors_rule {
      allowed_headers    = each.value.blob_properties.cors_rule.allowed_headers
      allowed_methods    = each.value.blob_properties.cors_rule.allowed_methods
      allowed_origins    = each.value.blob_properties.cors_rule.allowed_origins
      exposed_headers    = each.value.blob_properties.cors_rule.exposed_headers
      max_age_in_seconds = each.value.blob_properties.cors_rule.max_age_in_seconds
    }

    delete_retention_policy {
      days = each.value.blob_properties.delete_retention_policy.delete_retention_policy_days
    }

    container_delete_retention_policy {
      days = each.value.blob_properties.container_delete_retention_policy.container_delete_retention_policy_days
    }
  }
  }


  dynamic "custom_domain" {
    for_each = each.value.custom_domain != null ? [1] : []
  content {
    name          = each.value.custom_domain.custom_domain_name
    use_subdomain = each.value.custom_domain.custom_domain_use_subdomain
  }
  }
dynamic "share_properties" {
  for_each = (each.value.share_properties != null && ((each.value.account_tier == "Standard" && (each.value.account_kind == "Storage" || each.value.account_kind == "StorageV2")) || (each.value.account_tier == "Premium" && each.value.account_kind == "FileStorage"))) ? [1] : []
  content {
    cors_rule {
      allowed_headers    = each.value.share_properties.cors_rule.allowed_headers
      allowed_methods    = each.value.share_properties.cors_rule.allowed_methods
      allowed_origins    = each.value.share_properties.cors_rule.allowed_origins
      exposed_headers    = each.value.share_properties.cors_rule.exposed_headers
      max_age_in_seconds = each.value.share_properties.cors_rule.max_age_in_seconds
    }

    retention_policy {
      days = each.value.share_properties.retention_policy.retention_policy_days
    }

    smb {
      versions                        = each.value.share_properties.smb.smb_versions
      authentication_types            = each.value.share_properties.smb.smb_authentication_types
      kerberos_ticket_encryption_type = each.value.share_properties.smb.smb_kerberos_ticket_encryption_type
      channel_encryption_type         = each.value.share_properties.smb.smb_channel_encryption_type
      multichannel_enabled            = each.value.share_properties.smb.smb_multichannel_enabled
    }
  }
}
 dynamic "network_rules" {
  for_each = each.value.network_rules != null ? [1] : []
  content {
    default_action             = each.value.network_rules.default_action 
    bypass                     = each.value.network_rules.bypass
    ip_rules                   = each.value.network_rules.ip_rules
    virtual_network_subnet_ids = each.value.network_rules.virtual_network_subnet_ids

    private_link_access {

        endpoint_resource_id = each.value.private_link_access.endpoint_resource_id
        endpoint_tenant_id   = each.value.private_link_access.endpoint_tenant_id
      }
    }
  }




  dynamic "azure_files_authentication" {
      for_each = each.value.azure_files_authentication != null ? [1] : []
  content {
    directory_type = each.value.azure_files_authentication.directory_type

    active_directory {
      storage_sid         = each.value.azure_files_authentication.active_directory.storage_sid
      domain_name         = each.value.azure_files_authentication.active_directory.domain_name
      domain_sid          = each.value.azure_files_authentication.active_directory.domain_sid
      domain_guid         = each.value.azure_files_authentication.active_directory.domain_guid
      forest_name         = each.value.azure_files_authentication.active_directory.forest_name
      netbios_domain_name = each.value.azure_files_authentication.active_directory.netbios_domain_name
    }
  }
  }
  dynamic "identity" { 
  for_each = local.identity_configs[each.key].type != "" ? [1] : [] 
  content { 
    type = local.identity_configs[each.key].type 
  identity_ids = local.identity_configs[each.key].identity_ids 
  } 
  }
  

dynamic "customer_managed_key" {
  for_each = (each.value.customer_managed_key != null && (each.value.account_kind == "StorageV2" || each.value.account_tier == "Premium") && local.identity_configs[each.key].type  == "UserAssigned") ? [1] : []
  content {
    key_vault_key_id = each.value.customer_managed_key.key_vault_key_id
    user_assigned_identity_id = each.value.customer_managed_key.user_assigned_identity_id
  }
}





 dynamic "static_website" {
  for_each = (each.value.static_website != null && 
              (each.value.account_kind == "StorageV2" || each.value.account_kind == "BlockBlobStorage")) ? [1] : []
  content {
    index_document = each.value.static_website.index_document
    error_404_document = each.value.static_website.error_404_document
  }
}
}



  
