# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "random" {}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

resource "random_integer" "number" {
  min = 1000
  max = 9999
}

resource "azurerm_resource_group" "rg" {
  name     = "sockshop-${random_integer.number.result}-RG"
  location = "East US 2"

  tags = {
    environment = "Capstone"
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "sockshop-${random_integer.number.id}-AKS"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "sockshop-${random_integer.number.id}-K8S"
  kubernetes_version  = "1.28.10"

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_B2ms"
    os_disk_size_gb = 50
  }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  role_based_access_control_enabled = true

  tags = {
    environment = "Capstone"
  }
}
