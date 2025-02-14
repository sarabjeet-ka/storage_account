variable "storage_account_variables" {
  type = map(object({
    storage_account_name                              = string
    storage_account_resource_group_name               = string
    storage_account_location                          = string
account_kind                      = string
 account_tier                      = string
account_replication_type          = string
cross_tenant_replication_enabled  = bool
access_tier                       = string
edge_zone                         = string
    https_traffic_only_enabled      = bool
min_tls_version                   = string
allow_nested_items_to_be_public   = bool
shared_access_key_enabled         = bool
public_network_access_enabled     = bool
default_to_oauth_authentication   = bool
is_hns_enabled                    = bool
nfsv3_enabled                     = bool
large_file_share_enabled          = bool
queue_encryption_key_type         = string
table_encryption_key_type         = string
infrastructure_encryption_enabled = bool
sftp_enabled                      = bool

queue_properties = object({
      cors_rule = object({
        allowed_headers    = list(string)
        allowed_methods    = list(string)
        allowed_origins    = list(string)
        exposed_headers    = list(string)
        max_age_in_seconds = number
      })

logging = object({
        delete                = bool
        read                  = bool
        version               = string
        write                 = bool
        retention_policy_days = number
      })
      
      minute_metrics = object({
        enabled               = bool
        version               = string
        include_apis          = bool
        retention_policy_days = number
      })
      hour_metrics = object({
        enabled               = bool
        version               = string
        include_apis          = bool
        retention_policy_days = number
      })
    })

  blob_properties = object({
      versioning_enabled            = bool
      change_feed_enabled           = bool
      change_feed_retention_in_days = number
      default_service_version       = string
      last_access_time_enabled      = bool
      cors_rule = object({
        allowed_headers    = list(string)
        allowed_methods    = list(string)
        allowed_origins    = list(string)
        exposed_headers    = list(string)
        max_age_in_seconds = number
      })
      delete_retention_policy = object({
        delete_retention_policy_days = number
      })
      container_delete_retention_policy = object({
        container_delete_retention_policy_days = number
      })
    })
    custom_domain = object({
      custom_domain_name       = string
      custom_domain_use_subdomain = bool
    })
 
share_properties = object({
      cors_rule = object({
        allowed_headers    = list(string)
        allowed_methods    = list(string)
        allowed_origins    = list(string)
        exposed_headers    = list(string)
        max_age_in_seconds = number
      })
      retention_policy = object({
        retention_policy_days = number
      })
      smb = object({
        smb_versions                        = list(string)
        smb_authentication_types            = list(string)
        smb_kerberos_ticket_encryption_type = set(string)
        smb_channel_encryption_type         = set(string)
        smb_multichannel_enabled            = bool
      })
    })
    azure_files_authentication = object({
      directory_type = string
      active_directory = object({
        storage_sid         = string
        domain_name         = string
        domain_sid          = string
        domain_guid         = string
        forest_name         = string
        netbios_domain_name = string
      })
    })

 routing = object({
      publish_internet_endpoints  = bool
      publish_microsoft_endpoints = bool
      choice                      = string
    })

 immutability_policy = object({
      allow_protected_append_writes = bool
      state                         = string
      period_since_creation_in_days = number
    })

sas_policy = object({
      expiration_period = number
      expiration_action = string
    })
    network_rules = object({
      default_action             = string
      bypass                     = list(string)
      ip_rules                   = list(string)
      virtual_network_subnet_ids = list(string)
      private_link_access = list(object({
        endpoint_resource_id = string
        endpoint_tenant_id   = string
      }))
    })
use_user_assigned_identity=bool
use_system_assigned_identity=bool
user_identities = list(object({ 
    name = string 
resource_group_name = string 
}))
customer_managed_key = object({
      key_vault_key_id          = string
      user_assigned_identity_id = string
    })






  static_website = object({
      index_document     = string
      error_404_document = string
    })
    }))
}


