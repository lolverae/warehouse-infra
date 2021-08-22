provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "warehouse-service" {
  name     = "warehouse-service-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "warehouse-service" {
  name                = "warehouse-service-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.warehouse-service.location
  resource_group_name = azurerm_resource_group.warehouse-service.name
}

resource "azurerm_subnet" "warehouse-service" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.warehouse-service.name
  virtual_network_name = azurerm_virtual_network.warehouse-service.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "warehouse-service" {
  name                = "warehouse-service-nic"
  location            = azurerm_resource_group.warehouse-service.location
  resource_group_name = azurerm_resource_group.warehouse-service.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.warehouse-service.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "warehouse-service" {
  name                = "warehouse-service-machine"
  resource_group_name = azurerm_resource_group.warehouse-service.name
  location            = azurerm_resource_group.warehouse-service.location
  size                = "Standard_A1_v2"
  admin_username      = "ansadmin"
  network_interface_ids = [
    azurerm_network_interface.warehouse-service.id,
  ]

  admin_ssh_key {
    username   = "ansadmin"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "8-lvm-gen2"
    version   = "8.2.2020062401"
  }
}
