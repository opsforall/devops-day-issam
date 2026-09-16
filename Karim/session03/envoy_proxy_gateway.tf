resource "kubernetes_namespace" "envoy_gateway_system" {
  metadata {
    name = "envoy-gateway-system"
  }
}

resource "helm_release" "envoy_proxy_gateway" {
  name      = "epg"
  namespace = kubernetes_namespace.envoy_gateway_system.metadata[0].name
  chart     = "oci://docker.io/envoyproxy/gateway-helm"
  version   = "1.7.0"

  values     = [file("${path.root}/kubernetes/helm/envoy-proxy-gateway/values.yaml")]
  depends_on = [kubernetes_namespace.envoy_gateway_system]
}

resource "kubectl_manifest" "envoy_proxy" {
  yaml_body  = file("${path.root}/kubernetes/helm/envoy-proxy-gateway/manifests/envoyproxy.yaml")
  depends_on = [helm_release.envoy_proxy_gateway]
}
