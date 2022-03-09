
resource "google_cloudbuild_trigger" "c7n-container-trigger" {
  project = var.project

  trigger_template {
    project_id  = var.project
    branch_name = "^master$"
    repo_name   = "c7n"
  }

  build {
    timeout = "900s"
    #step {
    #  name       = "python"
    #  entrypoint = "pip3"
    #  args       = ["install", ".", "--user"]
    #}
    #step {
    #  name       = "python"
    #  entrypoint = "pip3"
    #  args       = ["install", ".", "--user"]
    #  dir        = "tools/c7n_gcp"
    #}
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "us-central1-docker.pkg.dev/$PROJECT_ID/cloud-custodian-repo/c7n:$SHORT_SHA", "."]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", "us-central1-docker.pkg.dev/$PROJECT_ID/cloud-custodian-repo/c7n:$SHORT_SHA"]
    }
    #step {
    #  name = "gcr.io/cloud-builders/docker"
    #  args = ["tag", "latest", "us-central1-docker.pkg.dev/$PROJECT_ID/cloud-custodian-repo/c7n:$SHORT_SHA"]
    #}
  }
}

resource "google_cloudbuild_trigger" "c7n-deploy-trigger" {
  project = var.project

  trigger_template {
    project_id  = var.project
    branch_name = "^master$"
    repo_name   = "c7n-policies"
  }

  build {
    step {
      name       = "us-central1-docker.pkg.dev/${var.project}/cloud-custodian-repo/c7n:${var.image_sha}"
      entrypoint = "bash"
      args       = ["-eEuo", "pipefail", "-c", "for i in $(find . -name '*.yaml'); do GOOGLE_CLOUD_PROJECT=\"$PROJECT_ID\" custodian run -s=/tmp $i; done"]
    }
  }
}

resource "google_cloudbuild_trigger" "infra-deploy-trigger" {
  project = var.project

  trigger_template {
    project_id  = var.project
    branch_name = "^main$"
    repo_name   = "infra-deploy"
  }

  filename = "infra-deploy.yaml"
}
