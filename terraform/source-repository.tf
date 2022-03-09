resource "google_sourcerepo_repository" "policy-repo" {
  project = var.project
  name    = "c7n-policies"
}

data "google_sourcerepo_repository" "repo" {
  project = var.project
  name    = "c7n"
}

data "google_sourcerepo_repository" "infa-repo" {
  project = var.project
  name    = "infra"
}

resource "google_sourcerepo_repository_iam_member" "member" {
  project    = data.google_sourcerepo_repository.repo.project
  repository = data.google_sourcerepo_repository.repo.name
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
