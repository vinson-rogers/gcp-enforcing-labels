
resource "google_artifact_registry_repository" "my-repo" {
  provider = google-beta

  project = var.project

  location      = "us-central1"
  repository_id = "cloud-custodian-repo"
  description   = "cloud custodian repo"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_member" "member" {
  provider   = google-beta
  project    = google_artifact_registry_repository.my-repo.project
  location   = google_artifact_registry_repository.my-repo.location
  repository = google_artifact_registry_repository.my-repo.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}
