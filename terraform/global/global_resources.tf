resource "azurerm_resource_group" "dev-rg" {
  name     = "dev-rg"
  location = "Central India"
  tags = {
    "Environment" = "dev"
    "CreatedByTerraform" = "true"
    "OwningProjects" = "All"
  }
}
