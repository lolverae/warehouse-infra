resource "azurerm_virtual_machine" "general-vms" {
  name                  = "${var.vm_name}-${count.index}"
  location              = "${azurerm_resource_group.warehouse-rg.location}"
  resource_group_name   = "${azurerm_resource_group.warehouse-rg.name}"
  network_interface_ids = ["${element(azurerm_network_interface.main.*.id, count.index)}"] #["${azurerm_network_interface.main.id}"]
  vm_size               = "Standard_A1_v2"
  count                 = "2"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "8_2"
    version   = "latest"
  }

  storage_os_disk {
    name              = "warehouse-osdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
