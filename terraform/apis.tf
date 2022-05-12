
resource "google_project_service" "enable_cloud_build" {
  project = var.project_id
  service = "cloudbuild.googleapis.com"
}

resource "google_project_service" "enable_cloud_run" {
  project = var.project_id
  service = "run.googleapis.com"
}

resource "google_project_service" "enable_artifact_registry" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "enable_pubsub" {
  project = var.project_id
  service = "pubsub.googleapis.com"
}

resource "google_project_service" "enable_cloud_functions" {
  project = var.project_id
  service = "cloudfunctions.googleapis.com"
}

resource "google_project_service" "enable_scc" {
  project = var.project_id
  service = "securitycenter.googleapis.com"
}

resource "google_project_service" "enable_cloud_scheduler" {
  project = var.project_id
  service = "cloudscheduler.googleapis.com"
}
