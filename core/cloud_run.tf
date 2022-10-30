resource "google_cloud_run_service" "server" {
  provider = google-beta

  name                       = "server"
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
      service_account_name = google_service_account.server_service_account.email

      containers {
        image = "asia-northeast1-docker.pkg.dev/${var.project_id}/docker/server:latest"

        resources {
          limits = {
            "memory" : "1Gi"
            "cpu" = "1000m"
          }
        }

        ports {
          container_port = 8080
          name           = "http1"
        }

        env {
          name  = "ENV"
          value = "production"
        }

        env {
          name  = "GCP_PROJECT_ID"
          value = var.project_id
        }

        env {
          name  = "GCP_REGION"
          value = var.region
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].metadata[0].annotations["run.googleapis.com/client-version"],
      template[0].metadata[0].annotations["client.knative.dev/user-image"],
      template[0].metadata[0].annotations["run.googleapis.com/client-name"],
      template[0].metadata[0].annotations["run.googleapis.com/sandbox"],
      metadata[0].annotations["client.knative.dev/user-image"],
      metadata[0].annotations["run.googleapis.com/client-name"],
      metadata[0].annotations["run.googleapis.com/client-version"],
    ]
  }
}

resource "google_cloud_run_service_iam_member" "public_access_server" {
  location = google_cloud_run_service.server.location
  project  = google_cloud_run_service.server.project
  service  = google_cloud_run_service.server.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

