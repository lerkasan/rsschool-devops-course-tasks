resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://charts.bitnami.com/bitnami" # oci://registry-1.docker.io/bitnamicharts
  chart      = "prometheus"
  version    = var.prometheus_chart_version

  namespace = "monitoring"

  values = [
    file("${path.root}/templates/values/prometheus-values.yml")
  ]

  depends_on = [
    kubernetes_namespace.monitoring,
    kubernetes_secret.smtp_auth
  ]
}

resource "helm_release" "kube-state-metrics" {
  name       = "kube-state-metrics"
  repository = "https://charts.bitnami.com/bitnami" # oci://registry-1.docker.io/bitnamicharts
  chart      = "kube-state-metrics"
  version    = var.kube_state_metrics_chart_version

  namespace = "kube-system"

  values = [
    file("${path.root}/templates/values/kube-state-metrics-values.yml")
  ]
}

resource "helm_release" "node-exporter" {
  name       = "node-exporter"
  repository = "https://charts.bitnami.com/bitnami" # oci://registry-1.docker.io/bitnamicharts
  chart      = "node-exporter"
  version    = var.node_exporter_chart_version

  namespace = "monitoring"

  values = [
    file("${path.root}/templates/values/node-exporter-values.yml")
  ]

  depends_on = [kubernetes_namespace.monitoring]
}


