provider "google" {
  credentials = var.GCP_CREDENTIALS
  project     = var.GCP_PROJECT_ID
  region      = var.GCP_PROJECT_REGION
}

provider "google-beta" {
  credentials = var.GCP_CREDENTIALS
  project     = var.GCP_PROJECT_ID
  region      = var.GCP_PROJECT_REGION
}

module "modules" {
  source     = "./modules"
  project_id = var.GCP_PROJECT_ID
  region     = var.GCP_PROJECT_REGION
}
