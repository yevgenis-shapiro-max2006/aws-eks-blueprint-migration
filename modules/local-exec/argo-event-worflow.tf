
resource "kubernetes_manifest" "velero_restore_events" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "EventSource"

    metadata = {
      name      = "velero-restore-events"
      namespace = "argo-events"
    }

    spec = {
      resource = {
        velero-restore = {
          namespace = "velero"
          group     = "velero.io"
          version   = "v1"
          resource  = "restores"

          eventTypes = [
            "UPDATE"
          ]
        }
      }
    }
  }
}


resource "kubernetes_manifest" "velero_restore_completed_sensor" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Sensor"

    metadata = {
      name      = "velero-restore-completed"
      namespace = "argo-events"
    }

    spec = {
      dependencies = [
        {
          name            = "restore-completed"
          eventSourceName = "velero-restore-events"
          eventName       = "velero-restore"

          filters = {
            data = [
              {
                path  = "body.status.phase"
                type  = "string"
                value = ["Completed"]
              }
            ]
          }
        }
      ]

      triggers = [
        {
          template = {
            name = "post-restore-validation"

            k8s = {
              operation = "create"

              source = {
                resource = {
                  apiVersion = "batch/v1"
                  kind       = "Job"

                  metadata = {
                    generateName = "velero-post-restore-"
                    namespace    = "default"
                  }

                  spec = {
                    backoffLimit = 3

                    template = {
                      spec = {
                        restartPolicy = "Never"

                        serviceAccountName = "post-restore-validator"

                        containers = [
                          {
                            name  = "validation"
                            image = "bitnami/kubectl:latest"

                            command = [
                              "/bin/sh",
                              "-c",
                              <<-EOT
                                set -e

                                echo "========================================"
                                echo "Velero restore completed"
                                echo "========================================"

                                echo
                                echo "Checking nodes..."
                                kubectl get nodes

                                echo
                                echo "Checking pods..."
                                kubectl get pods -A

                                echo
                                echo "Checking deployments..."
                                kubectl get deployments -A

                                echo
                                echo "Waiting for deployments..."
                                kubectl wait \
                                  --for=condition=Available \
                                  deployment \
                                  --all \
                                  --all-namespaces \
                                  --timeout=300s

                                echo
                                echo "========================================"
                                echo "Post-restore validation completed"
                                echo "========================================"
                              EOT
                            ]
                          }
                        ]
                      }
                    }
                  }
                }
              }
            }
          }
        }
      ]
    }
  }

  depends_on = [
    kubernetes_manifest.velero_restore_events
  ]
}
