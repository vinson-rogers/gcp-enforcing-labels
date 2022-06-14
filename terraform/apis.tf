
resource "google_project_service" "enable_api" {
  project  = var.project_id
  for_each = toset(var.apis)
  service  = each.value
}
