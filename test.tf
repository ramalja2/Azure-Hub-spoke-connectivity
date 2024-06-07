resource "azurerm_virtual_network" "testnetwork" {
  name                = "testnetwork"
  location            = azurerm_resource_group.testgroup.location
  resource_group_name = azurerm_resource_group.testgroup.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "testsubnet" {
  name                 = "testsubnet"
  resource_group_name  = azurerm_resource_group.testgroup.name
  virtual_network_name = azurerm_virtual_network.testnetwork.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_network_interface" "testnic" {
  name                = "testnic"
  location            = azurerm_resource_group.testgroup.location
  resource_group_name = azurerm_resource_group.testgroup.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.testsubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "testvm" {
  name                = "testvm"
  location            = azurerm_resource_group.testgroup.location
  resource_group_name = azurerm_resource_group.testgroup.name
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.testnic.id,
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

resource "azurerm_network_watcher" "testnetwatcher" {
  name                = "testnetwatcher"
  location            = azurerm_resource_group.testgroup.location
  resource_group_name = azurerm_resource_group.testgroup.name
}

resource "azurerm_network_security_group" "testnsg" {
  name                = "testnsg"
  location            = azurerm_resource_group.testgroup.location
  resource_group_name = azurerm_resource_group.testgroup.name

  security_rule {
    name                       = "testicmp"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.1.1.4"
    destination_address_prefix = "10.2.1.4"
  }

  security_rule {
    name                       = "testrdp"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "10.1.1.4"
    destination_address_prefix = "10.2.1.4"
  }
}

resource "azurerm_subnet_network_security_group_association" "testnsgassociate" {
  subnet_id                 = azurerm_subnet.testsubnet.id
  network_security_group_id = azurerm_network_security_group.testnsg.id
}
