terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 1) Create a new Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "cst8918-h09-rg"
  location = "canadacentral" # 
}

# 2) Create the AKS cluster
resource "azurerm_kubernetes_cluster" "app" {
  name                = "cst8918-h09-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "cst8918-h09"

  # Use the "SystemAssigned" managed identity
  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name                = "default"
    vm_size             = "Standard_B2s"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 3
  }

  kubernetes_version = null

}

# 3) Output the kubeconfig
output "kube_config" {
  description = "Kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.app.kube_config_raw
  sensitive   = true
}
