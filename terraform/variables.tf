variable org_id {}
variable region {}
variable project_id {}
variable function_bucket_name {}
variable function_location {}
variable "apis" {
  type = list(string)
  default = ["cloudresourcemanager.googleapis.com",
    "sourcerepo.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "pubsub.googleapis.com",
    "cloudfunctions.googleapis.com",
    "securitycenter.googleapis.com",
  "cloudscheduler.googleapis.com"]
}
