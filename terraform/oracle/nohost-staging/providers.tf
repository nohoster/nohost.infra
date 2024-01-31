provider "vault" {
  address = "https://vault.nohost.network"
}

data "vault_generic_secret" "oci-staging-secrets" {
  path = "nohost-secrets/oci-dev"
}

provider "oci" {
  tenancy_ocid = data.vault_generic_secret.oci-staging-secrets.data["tenancy"]
  user_ocid = data.vault_generic_secret.oci-staging-secrets.data["user"]
  private_key = data.vault_generic_secret.oci-staging-secrets.data["key_file"]
  fingerprint = data.vault_generic_secret.oci-staging-secrets.data["fingerprint"]
  region = data.vault_generic_secret.oci-staging-secrets.data["region"]
}
