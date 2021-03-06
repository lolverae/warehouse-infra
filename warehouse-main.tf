provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "warehouse-rg" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "warehouse-vnet" {
  name                = "${var.vnet_name}"
  location            = "${var.location}"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = "${azurerm_resource_group.warehouse-rg.name}"
}

resource "azurerm_subnet" "warehouse-subnet1" {
  name                 = "warehouse-subnet1"
  virtual_network_name = "${azurerm_virtual_network.warehouse-vnet.name}"
  resource_group_name  = "${azurerm_resource_group.warehouse-rg.name}"
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "warehouse-subnet2" {
  name                 = "warehouse-subnet2"
  virtual_network_name = "${azurerm_virtual_network.warehouse-vnet.name}"
  resource_group_name  = "${azurerm_resource_group.warehouse-rg.name}"
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "${var.vm_name}-nic-${count.index}"
  location            = "${azurerm_resource_group.warehouse-rg.location}"
  resource_group_name = "${azurerm_resource_group.warehouse-rg.name}"
  count               = "3"

  ip_configuration {
    name                          = "warehouse-ip${count.index}"
    subnet_id                     = "${azurerm_subnet.warehouse-subnet1.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.wareip[count.index].id}"
  }
}
resource "azurerm_public_ip" "wareip" {
  name                = "${var.vm_name}-ip-${count.index}"
  resource_group_name = "${azurerm_resource_group.warehouse-rg.name}"
  location            = "${azurerm_resource_group.warehouse-rg.location}"
  allocation_method   = "Static"
  count               = "3"
}