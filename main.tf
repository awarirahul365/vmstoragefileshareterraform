terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.43.0"
    }
  }
}

provider "azurerm" {
  features {}

  skip_provider_registration = true

  subscription_id = "b437f37b-b750-489e-bc55-43044286f6e1"
}

module "createafsvm" {
  source           = "./modules/suseafs"
  for_each         = var.virtual_machines
  storage_accounts = var.storage_accounts
  vmname           = each.value.vmname
  vnetname         = each.value.vnetname
  vnetcidr         = each.value.vnetcidr
  subnetname       = each.value.subnetname
  subnetcidr       = each.value.subnetcidr
  publicip         = each.value.publicip
  zonespip         = each.value.zonespip
  nsgname          = each.value.nsgname
  nicname          = each.value.nicname
  zonesvm          = each.value.zonesvm

}
