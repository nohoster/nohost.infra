data "oci_core_images" "os" {
  compartment_id           = oci_identity_compartment.staging-compartment.id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_instance" "control" {
    # Required
    count = var.control_number
    availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
    compartment_id = oci_identity_compartment.staging-compartment.id
    shape = "VM.Standard.A1.Flex"
    display_name = "control${count.index}"
    shape_config {
        ocpus         = 1
        memory_in_gbs = 6
    }
    source_details {
        source_id = data.oci_core_images.os.images[0].id
        source_type = "image"
    }
    create_vnic_details {
        hostname_label = "control${count.index}"
        assign_public_ip = true
        assign_private_dns_record= true
        subnet_id = oci_core_subnet.vcn-subnet.id
    }
    metadata = {
        ssh_authorized_keys = var.ssh_authorized_keys
    } 
    preserve_boot_volume = false

    provisioner "local-exec" {
        command = "IP=${ self.public_ip } NODE_TYPE=${ self.display_name } CLUSTER='staging' bash bootstrap.sh"
    }
}
resource "oci_core_instance" "worker" {
    # Required
    count = var.worker_number
    availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
    compartment_id = oci_identity_compartment.staging-compartment.id
    shape = "VM.Standard.A1.Flex"
    display_name = "worker${count.index}"
    shape_config {
        ocpus         = 1
        memory_in_gbs = 6
    }
    source_details {
        source_id = data.oci_core_images.os.images[0].id
        source_type = "image"
    }
    create_vnic_details {
        hostname_label = "worker${count.index}"
        assign_public_ip = true
        subnet_id = oci_core_subnet.vcn-subnet.id
    }
    metadata = {
        ssh_authorized_keys = var.ssh_authorized_keys
    } 
    preserve_boot_volume = false

    provisioner "local-exec" {
        command = "IP=${ self.public_ip } SERVER_IP=${ oci_core_instance.control[0].public_ip } NODE_TYPE=${ self.display_name } CLUSTER='staging' bash bootstrap.sh"
    }
}
