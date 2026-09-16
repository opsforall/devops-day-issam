resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  version    = "v1.19.0" # Specify the desired version
  values     = [file("${path.root}/kubernetes/helm/cert-manager/values.yaml")]
  depends_on = [kubernetes_namespace.cert_manager]
}

resource "kubectl_manifest" "cluster_issuer" {
  yaml_body  = file("${path.root}/kubernetes/helm/cert-manager/manifests/cluster-issuer.yaml")
  depends_on = [helm_release.cert_manager]
}
