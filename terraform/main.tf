# Azure Provider source and version being used
terraform {
    required_providers {
        azurerm = {
        source  = "hashicorp/azurerm"
        version = "=3.77.0"
        }
    }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
    features {}
}

# Main resource group
resource "azurerm_resource_group" "rg_main" {
    name     = var.resource_group
    location = var.location
}

# Container Registry
resource "azurerm_container_registry" "acr" {
    name                     = var.container_registry_name
    resource_group_name      = azurerm_resource_group.rg_main.name
    location                 = azurerm_resource_group.rg_main.location
    sku                      = "Standard"
}

# Cluster Kubernetes
resource "azurerm_kubernetes_cluster" "aks" {
    name                = var.k8s_cluster_name
    location            = azurerm_resource_group.rg_main.location
    resource_group_name = azurerm_resource_group.rg_main.name
    dns_prefix          = var.k8s_cluster_name
    default_node_pool {
        name       = "default"
        node_count = 1
        vm_size    = "Standard_B2s"
    }
    identity {
        type = "SystemAssigned"
    }
}

# Adresse IP public for the cluster
resource "azurerm_public_ip" "aks_public_ip" {
    name                = var.aks_public_ip
    location            = azurerm_kubernetes_cluster.aks.location
    resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group
    allocation_method   = "Static"
    sku                 = "Standard"  
}

# Role assignment for cluster to pull images from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
    scope                = azurerm_container_registry.acr.id
    role_definition_name = "AcrPull"
    principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

# Role assignment to push images to ACR
resource "azurerm_role_assignment" "acr_push" {
    scope                = azurerm_container_registry.acr.id
    role_definition_name = "AcrPush"
    principal_id         = data.azurerm_client_config.current.object_id
}





