resource "azurerm_resource_group" "hubgroup" {
  name     = "hubgroup"
  location = "eastus"
}

resource "azurerm_resource_group" "testgroup" {
  name     = "testgroup"
  location = "centralus"
}

resource "azurerm_resource_group" "devgroup" {
  name     = "devgroup"
  location = "westus"
}


resource "azurerm_virtual_network_peering" "hubtodev" {
  name                         = "hubtodev"
  resource_group_name          = azurerm_resource_group.hubgroup.name
  virtual_network_name         = azurerm_virtual_network.hubnetwork.name
  remote_virtual_network_id    = azurerm_virtual_network.devnetwork.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "devtohub" {
  name                         = "devtohub"
  resource_group_name          = azurerm_resource_group.devgroup.name
  virtual_network_name         = azurerm_virtual_network.devnetwork.name
  remote_virtual_network_id    = azurerm_virtual_network.hubnetwork.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}


resource "azurerm_virtual_network_peering" "hubtotest" {
  name                         = "hubtotest"
  resource_group_name          = azurerm_resource_group.hubgroup.name
  virtual_network_name         = azurerm_virtual_network.hubnetwork.name
  remote_virtual_network_id    = azurerm_virtual_network.testnetwork.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "testtohub" {
  name                         = "testtohub"
  resource_group_name          = azurerm_resource_group.testgroup.name
  virtual_network_name         = azurerm_virtual_network.testnetwork.name
  remote_virtual_network_id    = azurerm_virtual_network.hubnetwork.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
