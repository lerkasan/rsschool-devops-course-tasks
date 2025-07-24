variable "k8s_config_path" {
  description = "Kubernetes config path"
  type        = string
  default     = "~/.kube/config"
}

variable "k8s_config_context" {
  description = "Kubernetes config context"
  type        = string
  default     = "default"
}

variable "prometheus_chart_version" {
  description = "Version of the Prometheus Helm chart"
  type        = string
  default     = "2.1.16"
}

variable "kube_state_metrics_chart_version" {
  description = "Version of the kube-state-metrics Helm chart"
  type        = string
  default     = "5.0.14"
}

variable "node_exporter_chart_version" {
  description = "Version of the node-exporter Helm chart"
  type        = string
  default     = "4.5.17"
}

variable "cadvisor_chart_version" {
  description = "Version of the cAdvisor Helm chart"
  type        = string
  default     = "0.1.11"
}

variable "grafana_chart_version" {
  description = "Version of the Grafana Helm chart"
  type        = string
  default     = "12.1.1"
}