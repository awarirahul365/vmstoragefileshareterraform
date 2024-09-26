variable "vnetname" {
  type = string
}
variable "vnetcidr" {
  type = list(string)
}
variable "subnetname" {
  type = string
}
variable "subnetcidr" {
  type = list(string)
}
variable "publicip" {
  type = string
}
variable "zonespip" {
  type = list(string)
}
variable "nsgname" {
  type = string
}
variable "nicname" {
  type = string
}
variable "vmname" {
  type = string
}
variable "zonesvm" {
  type = string
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
