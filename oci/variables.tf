variable "region" {
  default = "ap-osaka-1"
}

variable "tenancy_ocid" {
  default = "ocid1.tenancy.oc1..aaaaaaaaqawll3rbpn256fbuqh5ubi62skskkmnigbdqgb6u6ozb35dm5b2a"
}
variable "user_ocid" {
  default = "ocid1.user.oc1..aaaaaaaageskhzdrmsiadeibv2x3cozslrljm3nnnx5zztqpjcje6fvlru2a"
}
variable "compartment_ocid" {
  default = "ocid1.tenancy.oc1..aaaaaaaaqawll3rbpn256fbuqh5ubi62skskkmnigbdqgb6u6ozb35dm5b2a"
}
variable "private_key_path" {
  default = "/home/yuto_kohama/.oci/oci_api_key.pem"
}
variable "fingerprint" {
  default = "33:c5:ba:df:71:59:44:06:7a:74:06:cf:13:c1:71:fd"
}

variable "availability_domain" {
  default = "UKIZ:AP-OSAKA-1-AD-1"
}

variable "ssh_public_key_path" {
  default = "/home/yuto_kohama/.ssh/oci_terraform_key.pub" # フルパスでもOK
}

variable "image_ocid_1" {
  description = "Instance 1 用の OS イメージ OCID"
  default     = "ocid1.image.oc1.ap-osaka-1.aaaaaaaaflfi3ylwcgxksvwae7z3e6dmxj5obsabsqytpo24ltqnamoidxuq"
}

variable "image_ocid_2" {
  description = "Instance 2 用の OS イメージ OCID"
  default     = "ocid1.image.oc1.ap-osaka-1.aaaaaaaaflfi3ylwcgxksvwae7z3e6dmxj5obsabsqytpo24ltqnamoidxuq"
}

variable "my_ip_cidr" {
  description = "自分のグローバルIP（SSH用）"
  default     = "60.71.16.38/32"
}
