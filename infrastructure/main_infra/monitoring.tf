# Install Prometheus + Grafana
resource "helm_release" "prometheus" {
  depends_on = [module.eks.cluster_id]
  provider = helm.eks_cluster

  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  create_namespace = true

  set = [{
    name  = "grafana.enabled"
    value = "true"
  }]
}