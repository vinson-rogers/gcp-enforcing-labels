# 1. Overview & Setup

Using this document you will learn how to automate the enforcement and auditing of labels for resources on Google Cloud Platform.  We will be using the following tools and GCP services to facilitate this:

- Terraform Compliance
- Cloud Custodian
- Jinja2
- Cloud Source Repository (CSR)
- Cloud Build
- Artifact Registry
- Cloud Functions
- Cloud Pub/Sub

The procedure involves the following steps:

1. Clone project repository
2. Customize terraform.tfvars for your environment
3. Deploy resources via Terraform
4. Add required inputs to jinja2 input file
5. (optional) Customize Cloud Custodian actions
6. Push input YAML to repo 'c7n-policies'
7. (automatic) Run Cloud Build jobs
8. (automatic) Deploy Cloud Custodian resources
9. run example infra-deploy pipeline with terraform compliance feature

## 1.1 Authenticating to GCP

In order to deploy your resources into GCP you will need to authenticate first and set the credentials for subsequent Terraform runs to use. Using the gcloud CLI execute the following:

`gcloud auth application-default login`


If you are not currently logged in this will open a browser window and you will log in using your existing GCP user account. Once complete you can list the current gcloud configuration:

`gcloud config list`


Example output:
```
[compute]
region = us-central1
zone = us-central1-a
[core]
account = user@domain
disable_usage_reporting = True
project = a_project_id

Your active configuration is: [default]
```

These defaults would be used in the absence of specific project targets in Terraform. We will be explicitly setting these values for any resources deployed in our example Terraform.

# 2. Terraform Compliance

Using Terraform Compliance in your CI/CD pipeline allows the ability to enforce specific aspects of configurations before resources are deployed to GCP. This prevents the accumulation of improperly labeled resources that would need to be audited and updated.

## 2.1 Feature File

Feature files use behavior driven development (BDD) to define the rules to apply to the Terraform plan file.

For the use case of enforcing labels we will have one feature file with one scenario per label being required:

```
Feature: Require Labels 
 
Scenario: owner 
 Given I have resource that supports labels defined 
 When it has labels 
 Then it must have labels 
 Then it must contain owner 
 
Scenario: environment 
 Given I have resource that supports labels defined 
 When it has labels 
 Then it must have labels 
 Then it must contain environment 
 And its value must match the "^(dev|test|prod)$" regex 
```

We will be automating the generation of the features file used to enforce labels for GCP resources defined in Terraform. 

## 2.2 Using Terraform Compliance

Once the feature file is created and pushed to your repository it will be referenced in a build step that gates the deployment:

terraform-compliance -f git:https://github.com/user/repo -p plan.out


Only a successful result should allow continuing to the   terraform apply   step.

# 3. Cloud Custodian

Cloud Custodian is a Python based policy engine. It uses YAML to define the policies, acting on specific GCP API methods, selecting resources based on defined filters, and finally performing actions. 

Example policy file:
```
policies:
  - name: specific-label-exists
    resource: gcp.instance
    mode:
      type: gcp-audit
      methods:
        - beta.compute.instances.insert
    filters:
      - or:
        - "tag:owner": absent
        - "tag:application": absent
    actions:
      - type: notify
        to:
          - <RECIPIENT>
        template: policy-template
        transport:
          type: pubsub
          topic: projects/<PROJECT_ID>/topics/<TOPIC_NAME>
```

The policy above checks for the absence of any of the listed labels (Cloud Custodian uses the same ‘tag’ implementation for GCP & AWS) and executes the actions if any of the filters return true.

# 4. Jinja2 Templates

In this section we’ll cover the jinja2 templates for each target application configuration. 

## 4.1 Template Inputs

The following jinja2 templates implement checks the following types:

- LABELS - these are only tested for their presence
- LIST - values are from the list of options defined
- REGEX - a regular expression defining the values allowed

The example input file defines each of these types of checks. Add the additional labels as necessary for your use case.

The variables at the end of the file are for Cloud Custodian notification actions.

required-labels-input.yaml:
```
LABELS:
  - owner
  - application

LIST:
  environment:
    name: environment
    list: [dev, staging, prod]

REGEX:
  version:
    name: version
    regex: ^[0-9]\.[0-9]\.[0-9]$

to_address: vinsonr
topic: custodian-notifications
project_id: prod-sh-t1-app-300917
```


## 4.2 c7n Template

The Cloud Custodian jinja2 template used to render the appropriate YAML config file is shown below.

templates/c7n-require-labels.j2:
```
policies:
  - name: specific-label-exists
    resource: gcp.instance
    mode:
      type: gcp-audit
      methods:
        - beta.compute.instances.insert
    filters:
      - or:
{%- for label in LABELS %}
        - "tag:{{ label }}": absent
{%- endfor %}
{%- for label in LIST %}
        - type: value
          key: tag:{{ LIST[label].name }}
          op: in
          value: {{LIST[label].list}}
{%- endfor %}
{%- for label in REGEX %}
        - type: value
          key: tag:{{ REGEX[label].name }}
          op: regex
          value: '{{ REGEX[label].regex }}'
{%- endfor %}
    actions:
      - type: notify
        to:
          - {{ to_address }}
        template: policy-template
        transport:
          type: pubsub
          topic: projects/{{ project_id}}/topics/{{ topic }}
```

## 4.3 Terraform Compliance Template

The Terraform Compliance  jinja2 template used to render the appropriate BDD config file is shown below.

templates/tf-compliance-require-labels.j2:
```
Feature: Require Labels
{% for label in LABELS %}
Scenario: {{ label }}
    Given I have resource that supports labels defined
    When it has labels
    Then it must have labels
    Then it must contain {{ label }}
{% endfor %}
{%- for label in LIST %}
Scenario: {{ label }}
    Given I have resource that supports labels defined
    When it has labels
    Then it must have labels
    Then it must contain {{ label }}
    And its value must match the "^(a|b|c)$" regex
{% endfor %}
{%- for label in REGEX %}
Scenario: {{ label }}
    Given I have resource that supports labels defined
    When it has labels
    Then it must have labels
    Then it must contain {{ label }}
    And its value must match the "{{ REGEX[label].regex }}" regex
{% endfor %}
```


## 4.4 Rendering Both Templates

Once you have the two files you can render both of the target configuration files.

<TODO>



# 5. Terraform

In this section we’ll cover the Terraform necessary to set up your GCP resources and kickstart the CI/CD process for customizing and deploying Cloud Custodian and your Terraform Compliance configuration. These are all contained in the source repository and only need the terraform.tfvars file edited.

Documented below are several TF files used to enable APIs in the target project.

variables.tf:
```
variable org_id {}
variable project {}
variable image_sha {}
```

The following file defines a few variables including the target Organization ID which is used to provide securitycenter.adminViewer rights to the target project’s Cloud Build service account.

The image_sha variable is updated once a new image is built and tested.

terraform.tfvars:
```
org_id = "367171320111"
project = "prod-sh-t1-app-300917"
image_sha = "3800c22"
```


The project.tf file creates a project to host the subsequent resources in.

project.tf:
```
resource "google_project" "project" {
  project_id = var.project
}
```


iam.tf - the roles required to deploy and manage the resources:
```
resource "google_project_iam_member" "fixme_reduce_my_permissions" {
  project = var.project
  role    = "roles/editor"
  member  = "serviceAccount:${var.project}@appspot.gserviceaccount.com"
}

resource "google_organization_iam_member" "organization_iam_scc" {
  org_id = var.org_id
  role   = "roles/securitycenter.adminViewer"
  member = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}
```


apis.tf:
```
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
```


source-repository.tf - creates two repositories, one to host Cloud Custodian source code and one to host the policies:
```
resource "google_sourcerepo_repository" "policy-repo" {
  project = var.project
  name    = "c7n-policies"
}

data "google_sourcerepo_repository" "repo" {
  project = var.project
  name    = "c7n"
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
```


artifact-registry.tf - creates a repository to store the built container for use in subsequent steps:
```
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
```


cloud-build.tf- defines two triggers, one to build c7n itself and one to build and deploy the policies:
```
resource "google_cloudbuild_trigger" "c7n-container-trigger" {
  project = var.project

  trigger_template {
    project_id  = var.project
    branch_name = "^master$"
    repo_name   = "c7n"
  }

  build {
    timeout = "900s"
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "us-central1-docker.pkg.dev/$PROJECT_ID/cloud-custodian-repo/c7n:$SHORT_SHA", "."]
    }
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["push", "us-central1-docker.pkg.dev/$PROJECT_ID/cloud-custodian-repo/c7n:$SHORT_SHA"]
    }
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
```


# 6. Initial Bootstrap & Ongoing CI/CD

In this section we’ll cover the exact steps necessary to implement the c7n policies and show an example Cloud Build step that uses the Terraform Compliance policy.

Set up variables and create a working directory:

```
export PROJECT_ID = <YOUR_PROJECT_ID>
export WORKING_DIR = working-dir-labels
mkdir ~/$WORKING_DIR && cd ~/$WORKING_DIR
```

## 6.1 Clone project repo

Use the following command to clone the repository containing the Terraform and Jinja2 templates:

```
git clone https://github.com/vinson-rogers/gcp-enforcing-labels
cd ~/$WORKING_DIR/gcp-enforcing-labels
```


## 6.2 Customize Variables and Values

Edit the following files and update each for your environment and use case:

terraform.tfvars
required-labels-input.yaml

## 6.3 Deploy Terraform

This code should be incorporated into your centralized IaC. For demonstration purposes you can deploy it from your local workstation:

cd terraform
terraform apply


## 6.4 Clone Repos & Upload YAML

Run the following to clone the c7n-policies repo and upload the customized YAML:

```
gcloud source repos clone c7n-policies --project=$PROJECT_ID
cd ~/$WORKING_DIR/c7n-policies
cp ~/$WORKING_DIR/gcp-enforcing-lables/required-labels-input.yaml .
git add required-labels-input.yaml
git commit -m "initial commit of required-labels-input.yaml"
git push origin master
```


## 6.5 Run example infra deployment pipeline

You can use the example infra-deploy directory to run a build pipeline with the terraform compliance feature set up. If your resources are compliant with the input YAML it will pass and deploy the infrastructure.
