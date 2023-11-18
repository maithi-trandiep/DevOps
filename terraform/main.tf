# Azure Provider source and version being used
terraform {
    required_providers {
        azurerm = {
        source  = "hashicorp/azurerm"
        version = "=3.0.0"
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
    tags = {
        environment = "Terraform Lab"
    }
}

# Container Registry
resource "azurerm_container_registry" "acr" {
    name                     = var.container_registry_name
    resource_group_name      = azurerm_resource_group.rg_main.name
    location                 = var.location
    sku                      = "Standard"
}

# Cluster Kubernetes
resource "azurerm_kubernetes_cluster" "aks" {
    name                = var.k8s_cluster_name
    location            = var.location
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
    location            = var.location
    resource_group_name = azurerm_resource_group.rg_main.name
    allocation_method   = "Static"
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
    principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}





