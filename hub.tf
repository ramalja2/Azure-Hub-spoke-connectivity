
resource "azurerm_virtual_network" "hubnetwork" {
  name                = "hubnetwork"
  location            = azurerm_resource_group.hubgroup.location
  resource_group_name = azurerm_resource_group.hubgroup.name
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "hubsubnet" {
  name                 = "hubsubnet"
  resource_group_name  = azurerm_resource_group.hubgroup.name
  virtual_network_name = azurerm_virtual_network.hubnetwork.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_network_interface" "hubnic" {
  name                = "hubnic"
  location            = azurerm_resource_group.hubgroup.location
  resource_group_name = azurerm_resource_group.hubgroup.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hubsubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "hubvm" {
  name                = "hubvm"
  location            = azurerm_resource_group.hubgroup.location
  resource_group_name = azurerm_resource_group.hubgroup.name
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.hubnic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_network_security_group" "hubnsg" {
  name                = "hubnsg"
  location            = azurerm_resource_group.hubgroup.location
  resource_group_name = azurerm_resource_group.hubgroup.name

  security_rule {
    name                       = "hubicmp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefixes    = ["10.0.1.4", "10.1.1.4"]
    destination_address_prefix = "10.2.1.4"
  }

  security_rule {
    name                       = "hubrdp"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefixes    = ["10.0.1.4", "10.1.1.4"]
    destination_address_prefix = "10.2.1.4"
  }
}

resource "azurerm_subnet_network_security_group_association" "hubnsgassociate" {
  subnet_id                 = azurerm_subnet.hubsubnet.id
  network_security_group_id = azurerm_network_security_group.hubnsg.id
}

resource "azurerm_network_watcher" "hubnetwatcher" {
  name                = "hubnetwatcher"
  location            = azurerm_resource_group.hubgroup.location
  resource_group_name = azurerm_resource_group.hubgroup.name
}