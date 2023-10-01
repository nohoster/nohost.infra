provider "vault" {
  address = "https://almacen.nohost.network:8200"
}

data "vault_generic_secret" "oci-dev-secrets" {
  path = "nohost-secrets/oci-dev"
}

provider "oci" {
  tenancy_ocid = data.vault_generic_secret.oci-dev-secrets.data["tenancy"]
  user_ocid = data.vault_generic_secret.oci-dev-secrets.data["user"]
  private_key = data.vault_generic_secret.oci-dev-secrets.data["key_file"]
  fingerprint = data.vault_generic_secret.oci-dev-secrets.data["fingerprint"]
  region = data.vault_generic_secret.oci-dev-secrets.data["region"]
}