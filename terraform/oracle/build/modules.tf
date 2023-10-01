module "vcn" {
  source  = "oracle-terraform-modules/vcn/oci"
  version = ">=3.5.0"
  compartment_id = oci_identity_compartment.build-compartment.id
  region = data.vault_generic_secret.oci-build-secrets.data["region"]

  internet_gateway_route_rules = null
  local_peering_gateways = null
  nat_gateway_route_rules = null

  # Optional Inputs
  vcn_name = "buildnet"
  vcn_dns_label = "buildnet"
  vcn_cidrs = ["10.0.0.0/16"]
  
  create_internet_gateway = true
  create_nat_gateway = false
  create_service_gateway = false
  
}