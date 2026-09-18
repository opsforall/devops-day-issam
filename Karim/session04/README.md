# AKS tools - Session 04: Install kube-pometheus-stack pipelines

This session covers the installation of kubeflow pipelines using terraform

## Install kube-prometheus-stack in AKS
### kube-prometheus-stack config
1. Inside the folder `helm`, create folder named `kube-prometheus-stack`
2. Create a file named `values.yaml` in the folder `kube-prometheus-stack` and copy the following code

```bash
grafana:
  enabled: true
  adminUser: admin
  adminPassword: admin

prometheus:
  enabled: true
```

### Deploy kube-prometheus-stack 
#### Method 1: Manually
1. Zxecute these commands in your `terminal` (please ensure that you're connected to the cluster AKS):

```bash
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace -f kubernetes/helm/kube-prometheus-stack/values.yaml --wait=false
```

#### Method 2: Using Terraform
1. Create a file named `kube_prometheus_stack.tf` in the root folder and copy the following content inside it:

```bash
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
  depends_on = [helm_release.cert_manager]
}

resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  chart      = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = "69.3.2" # Specify the desired version

  values     = [file("${path.module}/kubernetes/helm/kube-prometheus-stack/values.yaml")]
  depends_on = [kubernetes_namespace.monitoring]
}
```

2. Push the code to your project `aks-tools` 

3. In your github repository, click on `Actions`

4. In the left panel, click on `Install tools`, click on `Run workflow`, choose `dev` workspace fill the field `cluster_name` with your own cluster name. Click on `Run workflow` under them.