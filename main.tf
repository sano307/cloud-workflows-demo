terraform {
  required_version = ">= 1.1.0, < 1.2.0"

  backend "gcs" {
    bucket = "YOUR_TFSTATE_BUCKET_NAME"
    prefix = "cloud-workflows-demo"
  }
}

provider "google" {
  project = "YOUR_PROJECT_NAME"
  region  = "asia-northeast1"
}

provider "google-beta" {
  project = "YOUR_PROJECT_NAME"
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
