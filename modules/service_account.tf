resource "google_service_account" "hasura_service_account" {
  account_id   = "hasura"
  display_name = "HasuraのCloud Run実行用"
}

# See: https://stackoverflow.com/questions/67863863/terraform-gcp-assign-iam-roles-to-service-account
resource "google_project_iam_binding" "hasura_service_account" {
  project = var.project_id
  count   = length(var.hasura_service_account_roles)
  role    = var.hasura_service_account_roles[count.index]
  members = [
    "serviceAccount:${google_service_account.hasura_service_account.email}"
  ]
}
