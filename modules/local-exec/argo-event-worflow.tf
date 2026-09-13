
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

  #depends_on = [
  #  helm_release.argo_events
  #]
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

                        containers = [
                          {
                            name  = "validation"
                            image = "bitnami/kubectl:latest"

                            command = [
                              "/bin/sh",
                              "-c",
                              <<-EOT
                                echo "Velero restore completed"
                                echo "Running post-restore validation..."

                                kubectl get pods -A
                                kubectl get deployments -A

                                echo "Post-restore validation completed"
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
