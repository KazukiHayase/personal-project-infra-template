resource "google_service_account" "server_service_account" {
  account_id   = "server"
  display_name = "ServerのCloud Run実行用"
}

# See: https://stackoverflow.com/questions/67863863/terraform-gcp-assign-iam-roles-to-service-account
resource "google_project_iam_binding" "server_service_account" {
  project = var.project_id
  count   = length(var.server_service_account_roles)
  role    = var.server_service_account_roles[count.index]
  members = [
    "serviceAccount:${google_service_account.server_service_account.email}"
  ]
}

