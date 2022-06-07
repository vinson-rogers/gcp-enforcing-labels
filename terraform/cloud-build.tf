resource "google_cloudbuild_trigger" "clone-c7n" {
  project = var.project_id

  name = "clone-c7n-repo"

  count = 0

  trigger_template {
    project_id = var.project_id
    # branch for dummy commit to trigger clone, push of c7n repo
    branch_name = "^c7n-tag$"
    repo_name   = "c7n"
  }

  build {
    timeout = "900s"
    substitutions = {
      _C7N_TAG = "0.9.15.0"
    }
    step {
      name = "gcr.io/cloud-builders/git"
      args = ["clone", "-b", "$_C7N_TAG", "--depth", "1", "https://github.com/cloud-custodian/cloud-custodian.git"]
    }
    step {
      name       = "gcr.io/cloud-builders/git"
      entrypoint = "bash"
      args       = ["-c", "mv cloud-custodian/* ."]
    }
    step {
      name = "gcr.io/cloud-builders/git"
      args = ["config", "--global", "user.email", "automated@localhost.com"]
    }
    step {
      name = "gcr.io/cloud-builders/git"
      args = ["config", "--global", "user.name", "Cloud Build"]
    }
    step {
      name = "gcr.io/cloud-builders/git"
      args = ["add", "."]
    }
    step {
      name = "gcr.io/cloud-builders/git"
      args = ["commit", "-m", "'automated commit'"]
    }
    step {
      name = "gcr.io/cloud-builders/git"
      args = ["push", "origin", "master"]
    }
  }
}

resource "google_cloudbuild_trigger" "c7n-container-trigger" {
  project = var.project_id

  name = "build-c7n-container"

  count = 0

  trigger_template {
    project_id  = var.project_id
    branch_name = "^main$"
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
  project = var.project_id

  name = "deploy-c7n-policies"

  trigger_template {
    project_id  = var.project_id
    branch_name = "^main"
    repo_name   = "c7n-policies"
  }

  build {
    step {
      name       = "python"
      entrypoint = "pip"
      args       = ["install", "-r", "requirements.txt", "--user"]
    }
    step {
      name       = "python"
      entrypoint = "bash"
      #args       = ["-c", "python render.py &&\ncp c7n-labels.yaml /workspace/c7n-labels.yaml"]
      args = ["-c", "python render.py"]
    }
    step {
      name       = "us-central1-docker.pkg.dev/${var.project_id}/cloud-custodian-repo/c7n:${var.image_sha}"
      entrypoint = "bash"
      #args       = ["-eEuo", "pipefail", "-c", "cp /workspace/c7n-labels.yaml . &&\nfor i in $(find . -name '*.yaml' ! -name required-labels-input.yaml); do GOOGLE_CLOUD_PROJECT=\"$PROJECT_ID\" custodian run -s=/tmp $i; done"]
      args = ["-eEuo", "pipefail", "-c", "for i in $(find . -name '*.yaml' ! -name required-labels-input.yaml); do GOOGLE_CLOUD_PROJECT=\"$PROJECT_ID\" custodian run -s=/tmp $i; done"]
    }
    artifacts {
      objects {
        location = "gs://${var.project_id}_artifact_bucket/enforcing_labels/"
        paths    = ["tf-compliance-labels.feature", "c7n-labels.yaml"]
      }
    }
  }
}

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
