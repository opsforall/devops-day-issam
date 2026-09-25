# AKS tools - Session 04: Install kube-pometheus-stack pipelines

This session covers the installation of kubeflow pipelines using terraform

## Install kube-prometheus-stack in AKS
### kube-prometheus-stack config
1. Create in the root directory a folder named `kubernetes`, inside `kubernetes` create a folder named `helm`. Inside the folder `helm`, create folder named `kube-prometheus-stack`
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
1. Execute these commands in your `terminal` (please ensure that you're connected to the cluster AKS):

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

### View Prometheus and Grafana

Run the following commands in two separate terminals, and keep both terminals open while using the dashboards.

#### Prometheus

```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090
```

Open [Prometheus](http://localhost:9090) in your browser.

#### Grafana

```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
```

Open [Grafana](http://localhost:3000) in your browser. With the `values.yaml` configuration above, sign in with username `admin` and password `admin`.

If you used a different configuration, retrieve the Grafana admin password using PowerShell:

```powershell
$password = kubectl get secret -n monitoring kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}"
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($password))
```

Press `Ctrl+C` in each terminal to stop port forwarding.
