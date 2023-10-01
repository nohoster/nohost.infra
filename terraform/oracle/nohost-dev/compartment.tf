resource "oci_identity_compartment" "dev-compartment" {
    compartment_id = data.vault_generic_secret.oci-dev-secrets.data["tenancy"]
    description = "Nohost development tenancy."
    name = "nohost-dev"
}