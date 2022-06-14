resource "google_sourcerepo_repository" "policy-repo" {
  project    = var.project_id
  name       = "c7n-policies"
  depends_on = [google_project_service.enable_api]
}

resource "google_sourcerepo_repository" "repo" {
  project    = var.project_id
  name       = "c7n"
  depends_on = [google_project_service.enable_api]
}

resource "google_sourcerepo_repository" "infra-repo" {
  project    = var.project_id
  name       = "infra-deploy"
  depends_on = [google_project_service.enable_api]
}

resource "google_sourcerepo_repository_iam_member" "member" {
  project    = google_sourcerepo_repository.repo.project
  repository = google_sourcerepo_repository.repo.name
  role       = "roles/viewer"
  member     = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_sourcerepo_repository_iam_member" "member2" {
  project    = google_sourcerepo_repository.policy-repo.project
  repository = google_sourcerepo_repository.policy-repo.name
  role       = "roles/viewer"
  member     = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_sourcerepo_repository_iam_member" "member3" {
  project    = google_sourcerepo_repository.policy-repo.project
  repository = google_sourcerepo_repository.infra-repo.name
  role       = "roles/viewer"
  member     = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}
