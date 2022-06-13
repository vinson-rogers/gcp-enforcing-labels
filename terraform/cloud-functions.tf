/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# bucket to house function source
resource "google_storage_bucket" "function_bucket" {
  project                     = var.project_id
  name                        = "${var.project_id}_${var.function_bucket_name}"
  location                    = var.function_location
  force_destroy               = true
  uniform_bucket_level_access = true
}

# package up cloud function
data "archive_file" "function_archive" {
  type        = "zip"
  source_dir  = "./cf-notify/"
  output_path = "./cf-notify/c7n-notification-processor.zip"
}

# uploads function zip with randomized suffix to trigger re-deployment of cloud function
resource "google_storage_bucket_object" "archive" {
  #name = format("%s#%s", "asset-inventory-to-cloud-dns.zip", data.archive_file.function_archive.output_md5)
  name   = "asset-inventory-to-cloud-dns.zip" # keep package name to prevent function from re-deploying
  bucket = google_storage_bucket.function_bucket.name
  source = data.archive_file.function_archive.output_path
}

resource "google_cloudfunctions_function" "function" {
  project     = var.project_id
  region      = var.region
  name        = "c7n-notification-processor"
  description = "processes c7n notifications"
  runtime     = "python38"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.c7n-notifications.id
    //service    = "pubsub.googleapis.com"
  }
  ingress_settings = "ALLOW_INTERNAL_ONLY"
  timeout          = 60
  entry_point      = "print_decoded"
  #entry_point = "justprintdata" # used for debugging asset feed & function trigger
}
