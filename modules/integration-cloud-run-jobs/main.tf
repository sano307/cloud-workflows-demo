#----------------------------------------------------------
# Artifact Registry
#----------------------------------------------------------
resource "google_artifact_registry_repository" "integration_cloud_run_jobs" {
  provider = google-beta

  location      = "asia-northeast1"
  repository_id = "integration-cloud-run-jobs"
  format        = "DOCKER"
}

#----------------------------------------------------------
# Cloud Workflows
#----------------------------------------------------------
resource "google_service_account" "integration_cloud_run_jobs" {
  account_id = "icrj-workflow"
}

variable "workflow_roles" {
  default = [
    "roles/logging.logWriter",
    "roles/run.admin"
  ]
}

resource "google_project_iam_member" "workflow" {
  for_each = toset(var.workflow_roles)
  role     = each.value
  member   = "serviceAccount:${google_service_account.integration_cloud_run_jobs.email}"
}

resource "google_workflows_workflow" "integration_cloud_run_jobs" {
  name            = "integration-cloud-run-jobs-workflow"
  region          = "asia-southeast1"
  service_account = google_service_account.integration_cloud_run_jobs.id
  source_contents = templatefile("${path.module}/workflow.yaml", {})
}
