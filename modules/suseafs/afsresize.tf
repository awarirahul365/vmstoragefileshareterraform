data "azurerm_resource_group" "rg" {
  name = "afs-autoextend-resize-rg"
}
locals {
  storage_filehare_tuple = flatten([
    for storage_key, storage_value in var.storage_accounts : [
      for fs_key, fs_value in storage_value.fileshares : {
        storage_account_name = storage_value.storagename
        fsname               = fs_value.fsname
        quota                = fs_value.quota
        enabled_protocol     = fs_value.enabled_protocol
      }
    ]
  ])
}
# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnetname
  address_space       = var.vnetcidr
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = var.subnetname
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnetcidr
}

# Create public IP
resource "azurerm_public_ip" "public_ip" {
  name                = var.publicip
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zonespip
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = var.nsgname
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "RDP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"         # RDP port
    source_address_prefix      = "165.1.238.44" # Specific source IP
    destination_address_prefix = "*"
  }

}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = var.nicname
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "${var.nicname}-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.vmname
  resource_group_name             = data.azurerm_resource_group.rg.name
  location                        = data.azurerm_resource_group.rg.location
  size                            = "Standard_DS1_v2"
  admin_username                  = "adminuser"
  admin_password                  = "Terraform@123!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "suse"
    offer     = "sles-15-sp5-basic"
    sku       = "gen2"
    version   = "latest"
  }
}

resource "azurerm_storage_account" "storage" {
  for_each                        = var.storage_accounts
  name                            = each.value.storagename
  resource_group_name             = data.azurerm_resource_group.rg.name
  location                        = data.azurerm_resource_group.rg.location
  account_tier                    = "Premium"
  account_replication_type        = "LRS"
  account_kind                    = "FileStorage"
  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_share" "FSShare" {

  for_each = tomap({
    for fileshare_element in local.storage_filehare_tuple : "${fileshare_element.storage_account_name}.${fileshare_element.fsname}" => fileshare_element
  })
  name                 = each.value.fsname
  storage_account_name = each.value.storage_account_name
  quota                = each.value.quota
  enabled_protocol     = each.value.enabled_protocol
  depends_on           = [azurerm_storage_account.storage]
}
