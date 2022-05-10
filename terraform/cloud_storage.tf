
#bucket for various artifacts
resource "google_storage_bucket" "artifact_bucket" {
  project                     = var.project_id
  name                        = "${var.project_id}_artifact_bucket"
  location                    = var.function_location
  force_destroy               = true
  uniform_bucket_level_access = true
}
