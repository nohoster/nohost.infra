resource "oci_identity_compartment" "staging-compartment" {
    compartment_id = data.vault_generic_secret.oci-staging-secrets.data["tenancy"]
    description = "Nohost staging tenancy."
    name = "nohost-staging"
}