# Generate random resource group name
resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

resource "random_pet" "azurerm_kubernetes_cluster_name" {
  prefix = "cluster"
}

resource "random_pet" "azurerm_kubernetes_cluster_dns_prefix" {
  prefix = "dns"
}

resource "azurerm_virtual_network" "aks" {
  name                = "aks-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.224.0.0/12"]
}

resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = ["10.224.0.0/16"]
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_network_security_group" "aks" {
  name                = "aks-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.aks.id
  network_security_group_id = azurerm_network_security_group.aks.id
}

module "aks" {
  source  = "Azure/aks/azurerm"
  version = "7.3.0"
  location                            = azurerm_resource_group.rg.location
  cluster_name                                = random_pet.azurerm_kubernetes_cluster_name.id
  resource_group_name                 = azurerm_resource_group.rg.name
  prefix                          = random_pet.azurerm_kubernetes_cluster_dns_prefix.id
  storage_profile_enabled = true
  storage_profile_blob_driver_enabled = var.use_blob_csi_driver
  admin_username = var.username
  network_plugin    = "kubenet"
  load_balancer_sku = "standard"
  agents_pool_name = "agentpool"
  agents_size = "Standard_B2ms"
  agents_count = var.node_count
  identity_type = "SystemAssigned"
  public_ssh_key = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
  rbac_aad = false
  vnet_subnet_id = azurerm_subnet.aks.id
  temporary_name_for_rotation = "temppool"
}

