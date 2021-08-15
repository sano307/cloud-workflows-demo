terraform {
  required_version = ">= 1.0.0, < 1.1.0"

  backend "gcs" {
    bucket = "test-kim-tf-state"
    prefix = "cloud-workflows-demo"
  }
}

provider "google" {
  project = "kim-inseo"
  region  = "asia-northeast1"
}

provider "google-beta" {
  project = "kim-inseo"
  region  = "asia-northeast1"
}

module "integration-cloud-source-repository" {
  source = "./modules/integration-cloud-source-repository"
}
