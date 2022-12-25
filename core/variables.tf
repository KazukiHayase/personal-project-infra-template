variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "hasura_service_account_roles" {
  type    = list(string)
  default = ["roles/secretmanager.secretAccessor"]
}
