variable "vm_name" {
  default = "minecraft-0101a"
}

variable "vm_shape" {
  default = "VM.Standard.A1.Flex"
}
variable "ocpus" {
  default = 2
}
variable "memory_in_gbs" {
  default = 8
}

variable "image_ocid" {
  default = "ocid1.image.oc1.ap-osaka-1.aaaaaaaaflfi3ylwcgxksvwae7z3e6dmxj5obsabsqytpo24ltqnamoidxuq"
}

variable "ssh_public_key_path" {
  default = "/home/yuto_kohama/.ssh/oci_terraform_key.pub" # フルパスでもOK
}

variable "compartment_ocid" {
  default = "ocid1.tenancy.oc1..aaaaaaaaqawll3rbpn256fbuqh5ubi62skskkmnigbdqgb6u6ozb35dm5b2a"
}

variable "availability_domain" {
  default = "UKIZ:AP-OSAKA-1-AD-1"
}

variable "subnet_id" {}

variable "nsg_id" {}
