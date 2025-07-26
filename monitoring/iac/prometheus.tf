resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "kubernetes_secret" "smtp_auth" {
  type = "kubernetes.io/basic-auth"
  immutable = true

  metadata {
    name      = "smtp-auth"
    namespace = "monitoring"
    labels = {
      "sensitive" = "true"
    }
  }
 
  data = {
    "username" = var.smtp_auth_username
    "password" = var.smtp_auth_password
  }

  depends_on = [kubernetes_namespace.monitoring]
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

resource "helm_release" "cadvisor" {
  name       = "cadvisor"
  repository = "https://charts.bitnami.com/bitnami" # oci://registry-1.docker.io/bitnamicharts
  chart      = "cadvisor"
  version    = var.cadvisor_chart_version

  namespace = "monitoring"

  values = [
    file("${path.root}/templates/values/cadvisor-values.yml")
  ]

  depends_on = [kubernetes_namespace.monitoring]
}

