resource "google_pubsub_topic" "c7n-notifications" {
  name    = "c7n-notifications"
  project = var.project_id
}
