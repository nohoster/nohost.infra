data "oci_identity_availability_domains" "ads" {
  compartment_id = data.vault_generic_secret.oci-dev-secrets.data["tenancy"]
}