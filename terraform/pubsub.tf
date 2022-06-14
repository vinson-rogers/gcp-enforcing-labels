resource "google_pubsub_topic" "c7n-notifications" {
  name       = "c7n-notifications"
  depends_on = [google_project_service.enable_api]
  project    = var.project_id
}
