resource "azurerm_virtual_network" "devnetwork" {
  name                = "devnetwork"
  location            = azurerm_resource_group.devgroup.location
  resource_group_name = azurerm_resource_group.devgroup.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "devsubnet" {
  name                 = "devsubnet"
  resource_group_name  = azurerm_resource_group.devgroup.name
  virtual_network_name = azurerm_virtual_network.devnetwork.name
  address_prefixes     = ["10.0.1.0/24"]

}

resource "azurerm_network_interface" "devnic" {
  name                = "devnic"
  location            = azurerm_resource_group.devgroup.location
  resource_group_name = azurerm_resource_group.devgroup.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.devsubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "devvm" {
  name                = "devvm"
  resource_group_name = azurerm_resource_group.devgroup.name
  location            = azurerm_resource_group.devgroup.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.devnic.id,
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


resource "azurerm_network_security_group" "devnsg" {
  name                = "devnsg"
  location            = azurerm_resource_group.devgroup.location
  resource_group_name = azurerm_resource_group.devgroup.name

  security_rule {
    name                       = "devicmp"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.0.1.4"
    destination_address_prefix = "10.2.1.4"
  }

  security_rule {
    name                       = "devrdp"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.0.1.4"
    destination_address_prefix = "10.2.1.4"
  }
}

resource "azurerm_subnet_network_security_group_association" "devnsgassociate" {
  subnet_id                 = azurerm_subnet.devsubnet.id
  network_security_group_id = azurerm_network_security_group.devnsg.id
}

resource "azurerm_network_watcher" "devnetwatcher" {
  name                = "devnetwatcher"
  location            = azurerm_resource_group.devgroup.location
  resource_group_name = azurerm_resource_group.devgroup.name
}