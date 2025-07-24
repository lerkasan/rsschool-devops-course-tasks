terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.37"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
  required_version = "~> 1.12.0"
}
