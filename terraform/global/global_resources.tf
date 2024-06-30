resource "azurerm_resource_group" "dev-rg" {
  name     = "dev-rg"
  location = "Central India"
  tags = {
    "Environment" = "dev"
    "CreatedByTerraform" = "true"
  }
}


resource "azurerm_virtual_network" "vnet-dev" {
  name = "vnet-dev"
  address_space = [
    "192.168.0.0/16"
  ]
  resource_group_name = azurerm_resource_group.dev-rg.name
  location = azurerm_resource_group.dev-rg.location
  tags = merge(azurerm_resource_group.dev-rg.tags, {
    "OwningProjects" = "All"
  })
}
