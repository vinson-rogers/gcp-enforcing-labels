
resource "google_project_iam_member" "most_privilege_approach" {
  project = var.project
  role    = "roles/editor"
  member  = "serviceAccount:${var.project}@appspot.gserviceaccount.com"
}

resource "google_organization_iam_member" "organization_iam_scc" {
  org_id = var.org_id
  role   = "roles/securitycenter.adminViewer"
  member = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}
