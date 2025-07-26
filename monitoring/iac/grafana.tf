resource "random_password" "grafana_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "kubernetes_secret" "grafana_admin_password" {
  type      = "Opaque"  
  immutable = true

  metadata {
    name      = "grafana-admin-password"
    namespace = "monitoring"
    labels = {
      "sensitive" = "true"
    }
  }

  data = {
    "GF_SECURITY_ADMIN_PASSWORD" = random_password.grafana_password.result
  }

  depends_on = [kubernetes_namespace.monitoring]
}

resource "kubernetes_secret" "grafana_datasources" {
  type      = "Opaque"
  immutable = true

  metadata {
    name      = "grafana-datasources-secret"
    namespace = "monitoring"
    labels = {
      "sensitive" = "true"
    }
  }

  data = {
    "datasources.yml" = file("${path.root}/templates/configs/grafana/datasources.yml")
  }

  depends_on = [kubernetes_namespace.monitoring]
}

resource "kubernetes_config_map" "grafana_dashboard_provider" {
  metadata {
    name      = "grafana-dashboard-provider"
    namespace = "monitoring"
  }

  data = {
    "dashboard-provider.yml" = "${file("${path.root}/templates/configs/grafana/dashboard-provider.yml")}"
  }

  depends_on = [kubernetes_namespace.monitoring]
}

resource "kubernetes_config_map" "grafana_dashboards" {
  for_each = fileset("${path.root}/templates/configs/grafana/dashboards/", "*.json")

  metadata {
    name      = join("-", ["grafana-dashboard", split(".", each.key)[0]])
    namespace = "monitoring"
  }

  data = {
    "${each.key}" = "${file("${path.root}/templates/configs/grafana/dashboards/${each.key}")}"
  }

  depends_on = [kubernetes_namespace.monitoring]
}

resource "kubernetes_config_map" "grafana_alerting" {
  metadata {
    name      = "grafana-alerting"
    namespace = "monitoring"
  }

  data = {
    "alerting.yml" = "${file("${path.root}/templates/configs/grafana/alerts/alerting.yml")}"
  }

  depends_on = [kubernetes_namespace.monitoring]
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://charts.bitnami.com/bitnami" # oci://registry-1.docker.io/bitnamicharts
  chart      = "grafana"
  version    = var.grafana_chart_version

  namespace = "monitoring"

  values = [
    file("${path.root}/templates/values/grafana-values.yml")
  ]

  depends_on = [
    kubernetes_secret.grafana_datasources,
    kubernetes_secret.grafana_admin_password,
    kubernetes_config_map.grafana_dashboard_provider,
    kubernetes_config_map.grafana_dashboards,
    kubernetes_config_map.grafana_alerting,
    kubernetes_secret.smtp_auth
  ]
}