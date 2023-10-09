terraform {
  required_version = ">= 1.4"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
    vault = {
      source = "hashicorp/vault"
      version = ">=3.20.0"
    }
  }
  #TODO: Move backend to S3 
}

