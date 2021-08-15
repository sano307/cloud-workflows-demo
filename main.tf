terraform {
  required_version = ">= 1.0.0, < 1.1.0"

  backend "gcs" {
    bucket = local.tfstate_bucket_name
    prefix = "cloud-workflows-demo"
  }
}

locals {
  project_name = "YOUR_PROJECT_NAME"
  tfstate_bucket_name = "TFSTATE_BUCKET_NAME"
}

provider "google" {
  project = local.project_name
  region  = "asia-northeast1"
}

provider "google-beta" {
  project = local.project_name
  region  = "asia-northeast1"
}

module "integration-cloud-source-repository" {
  source = "./modules/integration-cloud-source-repository"
}

module "integration-cloud-firestore" {
  source = "./modules/integration-cloud-firestore"
}

module "integration-cloud-api-gateway" {
  source = "./modules/integration-cloud-api-gateway"
}
