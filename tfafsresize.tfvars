virtual_machines = {
  "vm1" = {
    vnetname   = "azpoe-afsresize-bugfix-vnet"
    vnetcidr   = ["10.0.0.0/16"]
    subnetname = "azpoe-afsresize-bugfix-subnet"
    subnetcidr = ["10.0.1.0/24"]
    publicip   = "azpoe-afsresize-bugfix-pip"
    zonespip   = ["1"]
    nsgname    = "azpoe-afsresize-bugfix-nsg"
    nicname    = "azpoe-afsresize-bugfix-nic"
    zonesvm    = "1"
    vmname     = "azpoe-afsresize-bugfix-vm"
  }
}

storage_accounts = {
  "storageaccount1" = {
    storagename = "azpoeafsresizebugfix1"
    fileshares = {
      "share1" = {
        fsname           = "vol-install-azpoe1"
        quota            = 200
        enabled_protocol = "SMB"
      },
      "share2" = {
        fsname           = "vol-install-azpoe2"
        quota            = 200
        enabled_protocol = "SMB"
      }
    }
  }
}

# You can also set values for the other variables if needed, 
# but they are covered in the virtual_machines map.
