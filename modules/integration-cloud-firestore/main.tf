#----------------------------------------------------------
# Cloud Workflows
#----------------------------------------------------------
resource "google_service_account" "integration_cloud_firestore" {
  account_id = "icf-workflow"
}

variable "workflow_roles" {
  default = [
    "roles/logging.logWriter",
    "roles/firebase.developAdmin"
  ]
}

resource "google_project_iam_member" "workflow" {
  for_each = toset(var.workflow_roles)
  role     = each.value
  member   = "serviceAccount:${google_service_account.integration_cloud_firestore.email}"
}

resource "google_workflows_workflow" "integration_cloud_firestore" {
  name            = "integration-cloud-firestore-workflow"
  region          = "asia-southeast1"
  service_account = google_service_account.integration_cloud_firestore.id
  source_contents = templatefile("${path.module}/workflow.yaml", {})
}
