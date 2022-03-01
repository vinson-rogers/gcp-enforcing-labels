
resource "google_project_service" "enable_cloud_build" {
  project = var.project
  service = "cloudbuild.googleapis.com"
}

resource "google_project_service" "enable_cloud_run" {
  project = var.project
  service = "run.googleapis.com"
}

resource "google_project_service" "enable_artifact_registry" {
  project = var.project
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "enable_pubsub" {
  project = var.project
  service = "pubsub.googleapis.com"
}

resource "google_project_service" "enable_cloud_functions" {
  project = var.project
  service = "cloudfunctions.googleapis.com"
}

resource "google_project_service" "enable_scc" {
  project = var.project
  service = "securitycenter.googleapis.com"
}

resource "google_project_service" "enable_cloud_scheduler" {
  project = var.project
  service = "cloudscheduler.googleapis.com"
}