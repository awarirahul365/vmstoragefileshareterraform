variable "virtual_machines" {
  type = map(object({
    vnetname   = string
    vnetcidr   = list(string)
    subnetname = string
    subnetcidr = list(string)
    publicip   = string
    zonespip   = list(string)
    nsgname    = string
    nicname    = string
    zonesvm    = string
    vmname     = string
  }))
}

variable "storage_accounts" {
  type = map(object({
    storagename = string
    fileshares = map(object({
      fsname           = string
      quota            = number
      enabled_protocol = string
    }))
  }))
}
