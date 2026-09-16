resource "kubectl_manifest" "gateway_class" {
  yaml_body  = file("${path.root}/kubernetes/manifests/gatewayclass.yaml")
  depends_on = [kubectl_manifest.envoy_proxy, kubectl_manifest.certificate_grafana, kubectl_manifest.certificate_prometheus]
}

resource "kubectl_manifest" "gateway" {
  yaml_body  = file("${path.root}/kubernetes/manifests/gateway.yaml")
  depends_on = [kubectl_manifest.gateway_class]
}

resource "kubectl_manifest" "http_route_grafana" {
  yaml_body  = file("${path.root}/kubernetes/manifests/grafana-httproute.yaml")
  depends_on = [kubectl_manifest.gateway]
}

resource "kubectl_manifest" "http_route_prometheus" {
  yaml_body  = file("${path.root}/kubernetes/manifests/prometheus-httproute.yaml")
  depends_on = [kubectl_manifest.gateway]
}