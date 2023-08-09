resource random_string main {
  length           = 8
  upper            = false
  special          = false
}

resource random_string volume_id {
  length           = 8
  upper            = false
  special          = false
}

data "http" "icanhazip" {
   url = "http://icanhazip.com"
}

resource azurerm_storage_account main {
  name                     = "sa${random_string.main.result}"
  resource_group_name      = module.aks.node_resource_group
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_kind = "StorageV2"
  account_replication_type = "LRS"
  is_hns_enabled = true
  nfsv3_enabled = true
  sftp_enabled = true

  network_rules {  
    default_action         = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.aks.id]
    ip_rules = [chomp(data.http.icanhazip.response_body)]
  }
}

resource "azurerm_storage_account_local_user" "example" {
  name                 = "user1"
  storage_account_id   = azurerm_storage_account.main.id
  ssh_password_enabled = true

  permission_scope {
    permissions {
      create = true
      delete = true
      list = true
      read = true
      write = true
    }
    service       = "blob"
    resource_name = azurerm_storage_container.container.name
  }
}

resource "azurerm_storage_container" "container" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "kubernetes_persistent_volume" "pv_blob" {
  metadata {
    name = "pv-blob"

    annotations = {
      "pv.kubernetes.io/provisioned-by" = "blob.csi.azure.com"
    }
  }

  spec {
    capacity = {
      storage = "1Pi"
    }

    access_modes                     = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "azureblob-nfs-premium"

    persistent_volume_source {
      csi {
        driver = "blob.csi.azure.com"
        read_only = false
        volume_handle = "volume-${random_string.volume_id.result}"
        volume_attributes = {
          resourceGroup = module.aks.node_resource_group
          storageAccount = azurerm_storage_account.main.name
          containerName = azurerm_storage_container.container.name
          protocol = "nfs"
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "pvc_blob" {
  metadata {
    name = "pvc-blob"
  }

  spec {
    access_modes = ["ReadWriteMany"]

    resources {
      requests = {
        storage = "10Gi"
      }
    }

    volume_name        = "pv-blob"
    storage_class_name = "azureblob-nfs-premium"
  }
}