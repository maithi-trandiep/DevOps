output "public_ip" {
    value = azurerm_public_ip.aks_public_ip.ip_address
}
data "azurerm_client_config" "current" {
}