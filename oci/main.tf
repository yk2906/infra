terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  private_key_path = var.private_key_path
  fingerprint      = var.fingerprint
}

resource "oci_core_virtual_network" "vcn" {
  compartment_id = var.compartment_ocid
  cidr_block     = "10.0.0.0/16"
  display_name   = "vcn-20250802"
  dns_label      = "vcn20250802"
}

resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "internet-gateway"
  enabled        = true
}

resource "oci_core_route_table" "route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "default-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

resource "oci_core_security_list" "user_custom_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "user_custom_security_list"

  ingress_security_rules {
    protocol = "6" # TCP
    source   = var.my_ip_cidr
    tcp_options {
      min = 22
      max = 22
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

resource "oci_core_network_security_group" "my_nsg" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "my-nsg"
}

resource "oci_core_network_security_group_security_rule" "inbound_rule" {
  network_security_group_id = oci_core_network_security_group.my_nsg.id
  direction                 = "INGRESS"
  protocol                  = "all" # すべてのプロトコル
  source                    = "60.71.16.38/32"
  description               = "Allow all traffic from 60.71.16.38/32"
}

resource "oci_core_network_security_group_security_rule" "outbound_rule" {
  network_security_group_id = oci_core_network_security_group.my_nsg.id
  direction                 = "EGRESS"
  protocol                  = "all" # すべてのプロトコル
  destination               = "0.0.0.0/0"
  description               = "Allow all outbound traffic"
}


resource "oci_core_subnet" "subnet" {
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_virtual_network.vcn.id
  cidr_block          = "10.0.1.0/24"
  availability_domain = var.availability_domain
  display_name        = "subnet-20250802"

  route_table_id = oci_core_route_table.route_table.id

  security_list_ids = [
    oci_core_security_list.user_custom_security_list.id
  ]
}

resource "oci_core_instance" "instance_1" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = "dev-instance-0101z"
  shape               = "VM.Standard.A1.Flex"

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet.id
    assign_public_ip = true
    display_name     = "dev-instance-vnic-0101z"
    nsg_ids          = [oci_core_network_security_group.my_nsg.id]
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
  }

  source_details {
    source_type = "image"
    source_id   = var.image_ocid_1
  }

  shape_config {
    ocpus         = 2
    memory_in_gbs = 8
  }
}

resource "oci_core_instance" "instance_2" {
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = "dev-instance-0102z"
  shape               = "VM.Standard.A1.Flex"

  create_vnic_details {
    subnet_id        = oci_core_subnet.subnet.id
    assign_public_ip = true
    display_name     = "dev-instance-vnic-0102z"
    nsg_ids          = [oci_core_network_security_group.my_nsg.id]
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
  }

  source_details {
    source_type = "image"
    source_id   = var.image_ocid_2
  }

  shape_config {
    ocpus         = 2
    memory_in_gbs = 8
  }
}
