
resource "google_project_iam_member" "most_privilege_approach" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${var.project_id}@appspot.gserviceaccount.com"
}

resource "google_project_iam_member" "logging_admin" {
  project = var.project_id
  role    = "roles/logging.admin"
  member  = "serviceAccount:${var.project_id}@appspot.gserviceaccount.com"
}

resource "google_organization_iam_member" "perms" {
  org_id = var.org_id
  role   = "roles/editor"
  member = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}
resource "google_organization_iam_member" "organization_iam_scc" {
  org_id = var.org_id
  role   = "roles/securitycenter.adminViewer"
  member = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}
