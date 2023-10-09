resource "oci_core_subnet" "vcn-subnet"{

  # Required
  compartment_id = oci_identity_compartment.staging-compartment.id
  vcn_id = module.vcn.vcn_id
  cidr_block = "10.0.0.0/24"
 
  # Optional
  route_table_id = module.vcn.ig_route_id
  security_list_ids = [oci_core_security_list.security-list.id]
  display_name = "staging-subnet"

  dns_label = "stagingsub"
}