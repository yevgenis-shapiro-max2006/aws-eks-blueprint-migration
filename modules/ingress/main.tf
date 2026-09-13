
resource "kubernetes_ingress_v1" "velero-ui" {
  metadata {
    name      = "ingress-route-velero-ui"
    namespace = "velero-ui"
    annotations = {
      "konghq.com/strip-path" = "true"
      # Optional:
      # "konghq.com/protocols"                 = "https"
      # "konghq.com/https-redirect-status-code" = "301"
      # "cert-manager.io/cluster-issuer"      = "letsencrypt-prod"
    }
  }

  spec {
    ingress_class_name = "kong"

    tls {
      hosts       = ["migration.crypterio.co"]
      secret_name = "velero-tls"
    }

    rule {
      host = "migration.crypterio.co"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "velero-ui"
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
  }
}


resource "kubernetes_ingress_v1" "minio" {
  metadata {
    name      = "ingress-route-minio"
    namespace = "default"
    annotations = {
      "konghq.com/strip-path" = "true"
      # Optional:
      # "konghq.com/protocols"                  = "https"
      # "konghq.com/https-redirect-status-code" = "301"
      # "cert-manager.io/cluster-issuer"        = "letsencrypt-prod"
    }
  }

  spec {
    ingress_class_name = "kong"

    tls {
      hosts       = ["logs-s3.appflex.io"]
      secret_name = "loki-tls"
    }

    rule {
      host = "logs-s3.appflex.io"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "minio-console"
              port {
                number = 9001
              }
            }
          }
        }
      }
    }
  }
}
