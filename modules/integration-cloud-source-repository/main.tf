#----------------------------------------------------------
# Cloud Source Repository
#----------------------------------------------------------
resource "google_sourcerepo_repository" "cloud_workflows_demo" {
  name = var.sourcerepo_name
}

#----------------------------------------------------------
# Cloud Workflows
#----------------------------------------------------------
resource "google_service_account" "integration_cloud_source_repository" {
  account_id = "icsr-workflow"
}

variable "workflow_roles" {
  default = [
    "roles/logging.logWriter",
    "roles/cloudbuild.builds.builder"
  ]
}

resource "google_project_iam_member" "workflow" {
  for_each = toset(var.workflow_roles)
  role     = each.value
  member   = "serviceAccount:${google_service_account.integration_cloud_source_repository.email}"
}

resource "google_workflows_workflow" "integration_cloud_source_repository" {
  name            = "integration-cloud-source-repository-workflow"
  region          = "asia-southeast1"
  service_account = google_service_account.integration_cloud_source_repository.id
  source_contents = templatefile("${path.module}/workflow.yaml", {
    sourcerepo_name = split("/", google_sourcerepo_repository.cloud_workflows_demo.id)[3]
  })
}
