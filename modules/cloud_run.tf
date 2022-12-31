resource "google_cloud_run_service" "hasura" {
  provider = google-beta

  name                       = "hasura"
  location                   = var.region
  autogenerate_revision_name = true

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = "0"
        "autoscaling.knative.dev/maxScale" = "5"
      }
    }

    spec {
      service_account_name = google_service_account.hasura_service_account.email

      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/docker/hasura:latest"

        resources {
          limits = {
            "memory" : "512Mi"
            "cpu" = "1000m"
          }
        }

        ports {
          container_port = 8080
          name           = "http1"
        }

        env {
          name = "HASURA_GRAPHQL_DATABASE_URL"
          value_from {
            secret_key_ref {
              name = data.google_secret_manager_secret.secret_hasura_graphql_database_url.secret_id
              key  = "latest"
            }
          }
        }

        env {
          name = "HASURA_GRAPHQL_ADMIN_SECRET"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.secret_hasura_graphql_admin_secret.secret_id
              key  = "latest"
            }
          }
        }

        env {
          name  = "HASURA_GRAPHQL_ENABLE_CONSOLE"
          value = "true"
        }

        env {
          name  = "HASURA_GRAPHQL_UNAUTHORIZED_ROLE"
          value = "anyone"
        }

        env {
          name  = "HASURA_GRAPHQL_EXPERIMENTAL_FEATURES"
          value = "naming_convention"
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].metadata[0].annotations["client.knative.dev/user-image"],
      template[0].metadata[0].annotations["run.googleapis.com/client-name"],
      template[0].metadata[0].annotations["run.googleapis.com/client-version"],
      metadata[0].annotations["client.knative.dev/user-image"],
      metadata[0].annotations["run.googleapis.com/client-name"],
      metadata[0].annotations["run.googleapis.com/client-version"]
    ]
  }
}

resource "google_cloud_run_service_iam_member" "public_access_hasura" {
  location = google_cloud_run_service.hasura.location
  project  = google_cloud_run_service.hasura.project
  service  = google_cloud_run_service.hasura.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
