data "azurerm_platform_image" "openwebui" {
  location  = azurerm_resource_group.openwebui.location
  publisher = "Debian"
  offer     = "debian-11"
  sku       = "11"
}

/*
data "cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"

    content = file("${path.module}/scripts/provision_basic.sh")
  }

  part {
    content_type     = "text/cloud-config"
    content          = file("${path.module}/scripts/init.yaml")
  }
}
*/

resource "azurerm_resource_group" "openwebui" {
  name     = "example-resources"
  location = "eastus"
}

resource "azurerm_virtual_network" "openwebui" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.openwebui.name
  location            = azurerm_resource_group.openwebui.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "openwebui" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.openwebui.name
  virtual_network_name = azurerm_virtual_network.openwebui.name
  address_prefixes     = [cidrsubnet(tolist(azurerm_virtual_network.openwebui.address_space)[0], 8, 2 )]
}

resource "azurerm_network_security_group" "openwebui" {
  name                = "openwebui-nsg"
  location            = azurerm_resource_group.openwebui.location
  resource_group_name = azurerm_resource_group.openwebui.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "0.0.0.0/0" 
    destination_address_prefix  = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "openwebui" {
  subnet_id = azurerm_subnet.openwebui.id
  network_security_group_id = azurerm_network_security_group.openwebui.id
}
resource "azurerm_public_ip" "openwebui" {
  name                = "openwebui_ip"
  resource_group_name = azurerm_resource_group.openwebui.name
  location            = azurerm_resource_group.openwebui.location
  allocation_method   = "Static"
  }

resource "azurerm_network_interface" "openwebui" {
  name                = "example-nic"
  location            = azurerm_resource_group.openwebui.location
  resource_group_name = azurerm_resource_group.openwebui.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.openwebui.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.openwebui.id
  }
}

resource "azurerm_linux_virtual_machine" "openwebui" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.openwebui.name
  location            = azurerm_resource_group.openwebui.location
  size                = "Standard_A2_v2"
  admin_username      = "openwebui"
  network_interface_ids = [
    azurerm_network_interface.openwebui.id,
  ]

  admin_ssh_key {
    username   = "openwebui"
    public_key = file("C:/Users/Owner/Downloads/my-virtual-key.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }



  source_image_reference {
    publisher = data.azurerm_platform_image.openwebui.publisher
    offer     = data.azurerm_platform_image.openwebui.offer
    sku       = data.azurerm_platform_image.openwebui.sku
    version   = data.azurerm_platform_image.openwebui.version
  }
}