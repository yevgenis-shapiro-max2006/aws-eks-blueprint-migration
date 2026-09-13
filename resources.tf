
###  ---  Application  ---  ###
module "httpd" {
  source = "./modules/httpd"
  depends_on = [kubernetes_namespace.migration]

  name   = "httpd-server"
  namespace = "default"
  replicas  = 1
  image = "virtapp/apache:7f6c4bf4-3-6"
  service_port = 8080
  service_type = "ClusterIP"
}

module "kong" {
  source = "./modules/kong"
  depends_on = [module.httpd]
}

module "minio" {
  source = "./modules/minio"
  depends_on = [module.kong]
}

module "loki" {
  source = "./modules/loki"
  depends_on = [module.minio]
}

module "promtail" {
  source = "./modules/promtail"
  depends_on = [module.loki]
}

module "prometheus" {
  source = "./modules/prometheus"
  depends_on = [module.promtail]
}

module "grafana" {
  source = "./modules/grafana"
  depends_on = [module.prometheus]
}

module "ingress" {
  source = "./modules/ingress"
  depends_on = [module.grafana]
}

