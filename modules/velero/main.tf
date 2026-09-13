
resource "kubernetes_namespace_v1" "velero" {
  metadata {
    name = "velero"
  }
}


resource "kubernetes_secret_v1" "velero_cloud_credentials" {
  metadata {
    name      = "cloud-credentials"
    namespace = kubernetes_namespace_v1.velero.metadata[0].name
  }

  data = {
    cloud = <<-EOT
      [default]
      aws_access_key_id=${var.aws_access_key_id}
      aws_secret_access_key=${var.aws_secret_access_key}
    EOT
  }

  type = "Opaque"
}


resource "helm_release" "velero" {
  name             = "velero"
  namespace        = "velero"
  repository       = "https://vmware-tanzu.github.io/helm-charts"
  chart            = "velero"
  version          = "6.7.0"
  create_namespace = true

  set = [
  {
    name  = "credentials.existingSecret"
    value = "cloud-credentials"
  }
]

  values = [<<EOF
configuration:
  backupStorageLocation:
    - name: default
      provider: aws
      bucket: payplus-velero
      config:
        region: eu-west-2
        s3ForcePathStyle: "false"

  volumeSnapshotLocation:
    - name: default
      provider: aws
      config:
        region: eu-west-2


credentials:
  useSecret: true
  existingSecret: cloud-credentials


initContainers:
  - name: velero-plugin-for-aws
    image: velero/velero-plugin-for-aws:v1.8.0
    volumeMounts:
      - mountPath: /target
        name: plugins

deployNodeAgent: true

metrics:
  enabled: true
EOF
  ]
}
