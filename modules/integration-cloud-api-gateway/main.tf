#----------------------------------------------------------
# Cloud Functions
#----------------------------------------------------------
resource "google_storage_bucket" "functions" {
  name = "cm-test-kim-functions"
}

data "archive_file" "hello_get" {
  type        = "zip"
  source_dir  = "${path.module}/functions/hello"
  output_path = "tmp/hello_get.zip"
}

resource "google_storage_bucket_object" "hello_get" {
  name   = "hello_get-${data.archive_file.hello_get.output_md5}"
  bucket = google_storage_bucket.functions.name
  source = data.archive_file.hello_get.output_path
}

resource "google_cloudfunctions_function" "hello_get" {
  name        = "HelloGet"
  runtime     = "go113"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.functions.name
  source_archive_object = google_storage_bucket_object.hello_get.name
  trigger_http          = true
  entry_point           = "Get"
}

resource "google_cloudfunctions_function_iam_member" "hello_get_invoker" {
  project        = google_cloudfunctions_function.hello_get.project
  region         = google_cloudfunctions_function.hello_get.region
  cloud_function = google_cloudfunctions_function.hello_get.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

data "archive_file" "hello_post" {
  type        = "zip"
  source_dir  = "${path.module}/functions/hello"
  output_path = "tmp/hello_post.zip"
}

resource "google_storage_bucket_object" "hello_post" {
  name   = "hello_post-${data.archive_file.hello_post.output_md5}"
  bucket = google_storage_bucket.functions.name
  source = data.archive_file.hello_post.output_path
}

resource "google_cloudfunctions_function" "hello_post" {
  name        = "HelloPost"
  runtime     = "go113"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.functions.name
  source_archive_object = google_storage_bucket_object.hello_post.name
  trigger_http          = true
  entry_point           = "Post"
}

resource "google_cloudfunctions_function_iam_member" "hello_post_invoker" {
  project        = google_cloudfunctions_function.hello_post.project
  region         = google_cloudfunctions_function.hello_post.region
  cloud_function = google_cloudfunctions_function.hello_post.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

#----------------------------------------------------------
# Cloud API Gateway
#----------------------------------------------------------
resource "google_api_gateway_api" "demo" {
  provider = google-beta

  api_id = "test-kim-apigw-demo"
}

resource "google_api_gateway_api_config" "demo" {
  provider = google-beta

  api                  = google_api_gateway_api.demo.api_id
  api_config_id_prefix = "test-kim-apiconfig-demo-"

  openapi_documents {
    document {
      path = "${path.module}/apigw.yaml"
      contents = base64encode(
        templatefile("${path.module}/apigw.yaml", {
          hello_get_address = google_cloudfunctions_function.hello_get.https_trigger_url
          hello_post_address = google_cloudfunctions_function.hello_post.https_trigger_url
        })
      )
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_api_gateway_gateway" "demo" {
  provider = google-beta

  api_config = google_api_gateway_api_config.demo.id
  gateway_id = "test-kim-gateway-demo"
}

#----------------------------------------------------------
# Cloud Workflows
#----------------------------------------------------------
resource "google_service_account" "integration_cloud_api_gateway" {
  account_id = "icag-workflow"
}

variable "workflow_roles" {
  default = [
    "roles/logging.logWriter"
  ]
}

resource "google_project_iam_member" "workflow" {
  for_each = toset(var.workflow_roles)
  role     = each.value
  member   = "serviceAccount:${google_service_account.integration_cloud_api_gateway.email}"
}

resource "google_workflows_workflow" "integration_cloud_api_gateway" {
  name            = "integration-cloud-api-gateway-workflow"
  region          = "asia-southeast1"
  service_account = google_service_account.integration_cloud_api_gateway.id
  source_contents = templatefile("${path.module}/workflow.yaml", {
    apigw_hostname = google_api_gateway_gateway.demo.default_hostname
  })
}
