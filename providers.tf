terraform {
  required_version = ">=1.0"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>1.8"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.68.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.5.1"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.22.0"
    }
    http = {
      source = "hashicorp/http"
      version = "3.4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host = module.aks.host
  client_certificate     = base64decode(module.aks.client_certificate)
  client_key             = base64decode(module.aks.client_key)
  cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
}