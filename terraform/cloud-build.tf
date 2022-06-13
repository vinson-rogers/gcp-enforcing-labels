
resource "google_cloudbuild_trigger" "c7n-clone-build-deploy" {
  project = var.project_id
  name    = "c7n-clone-build-deploy"
  trigger_template {
    project_id  = var.project_id
    branch_name = "^master$"
    repo_name   = "c7n"
  }
  filename = "c7n-pipeline.yaml"
}

resource "google_cloudbuild_trigger" "infra-deploy-trigger" {
  project = var.project_id

  name = "example-infra-deploy"

  trigger_template {
    project_id  = var.project_id
    branch_name = "^main$"
    repo_name   = "infra-deploy"
  }

  filename = "infra-deploy.yaml"
}
