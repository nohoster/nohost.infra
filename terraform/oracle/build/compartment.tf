resource "oci_identity_compartment" "build-compartment" {
    compartment_id = data.vault_generic_secret.oci-build-secrets.data["tenancy"]
    description = "Nohost builders tenancy."
    name = "nohost-builders"
}