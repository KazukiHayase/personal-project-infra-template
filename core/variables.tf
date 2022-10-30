variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "server_service_account_roles" {
  type    = list(string)
  default = ["roles/datastore.user"]
}

