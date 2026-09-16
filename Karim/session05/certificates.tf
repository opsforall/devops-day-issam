resource "kubectl_manifest" "certificate_grafana" {
  yaml_body  = file("${path.root}/kubernetes/helm/cert-manager/manifests/certificate-grafana.yaml")
  depends_on = [kubectl_manifest.cluster_issuer]
}

resource "kubectl_manifest" "certificate_prometheus" {
  yaml_body  = file("${path.root}/kubernetes/helm/cert-manager/manifests/certificate-prometheus.yaml")
  depends_on = [kubectl_manifest.cluster_issuer]
}