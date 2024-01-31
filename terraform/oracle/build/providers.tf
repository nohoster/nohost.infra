provider "vault" {
  address = "https://vault.nohost.network"
}

data "vault_generic_secret" "oci-build-secrets" {
  path = "nohost-secrets/oci-build"
}

provider "oci" {
  tenancy_ocid = data.vault_generic_secret.oci-build-secrets.data["tenancy"]
  user_ocid = data.vault_generic_secret.oci-build-secrets.data["user"]
  private_key = data.vault_generic_secret.oci-build-secrets.data["key_file"]
  fingerprint = data.vault_generic_secret.oci-build-secrets.data["fingerprint"]
  region = data.vault_generic_secret.oci-build-secrets.data["region"]
}
