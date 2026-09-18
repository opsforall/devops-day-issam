# AKS tools - Session 05: Configure certificates and deploy gateway components 

This session covers the configuration of certificates and deploy of gateway components using terraform

## Create certificates using certmanager
1. Inside the folder `cert-manager`
2. Create a file named `certificate-grafana.yaml` in the folder `manifests` and copy the following code

```bash
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: grafana-pipelines-cert
  namespace: envoy-gateway-system
spec:
  secretName: grafana-tls
  dnsNames:
  - yourfullname-grafana.aks.karimarous.com
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt-prod
```

3. Create a file named `certificate-prometheus.yaml` in the folder `manifests` and copy the following code

```bash
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: prometheus-cert
  namespace: envoy-gateway-system
spec:
  secretName: prometheus-tls
  dnsNames:
  - yourfullname-prometheus.aks.karimarous.com
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt-prod
```

3. Replace your `yourfullname` in the dnsNmes with your name. Example `karimarous`
4. Create a file named `certificate.tf` in the root project and copy the following code:

```bash
resource "kubectl_manifest" "certificate_grafana" {
  yaml_body  = file("${path.root}/kubernetes/helm/cert-manager/manifests/certificate-grafana.yaml")
  depends_on = [kubectl_manifest.cluster_issuer]
}

resource "kubectl_manifest" "certificate_prometheus" {
  yaml_body  = file("${path.root}/kubernetes/helm/cert-manager/manifests/certificate-prometheus.yaml")
  depends_on = [kubectl_manifest.cluster_issuer]
}
```

## Configure gateway and create routes

1. Inside the folder `kubernetes`, create folder named `manifests`
2. Create a file named `gateway-class.yaml` in the folder `manifests` and copy the following code

```bash
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: gc-gateway-class
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
  parametersRef:
    group: gateway.envoyproxy.io
    kind: EnvoyProxy
    name: ep-envoy-proxy
    namespace: envoy-gateway-system
```

3. Create a file named `grafana-httproute.yaml` in the folder `manifests` and copy the following code

```bash
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: grafana-route
  namespace: monitoring
spec:
  parentRefs:
  - name: public-gateway
    namespace: envoy-gateway-system
  hostnames:
  - yourfullname-grafana.aks.karimarous.com
  rules:
  - backendRefs:
    - name: kube-prometheus-stack-grafana
      port: 80
```

Replace your `yourfullname` in the `hostnames` with your name. Example `karimarous`

3. Create a file named `prometheus-httproute.yaml` in the folder `manifests` and copy the following code

```bash
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: prometheus-route
  namespace: monitoring
spec:
  parentRefs:
  - name: public-gateway
    namespace: envoy-gateway-system
  hostnames:
  - yourfullname-prometheus.aks.karimarous.com
  rules:
  - backendRefs:
    - name: kube-prometheus-stack-prometheus
      port: 9090
```

Replace your `yourfullname` in the `hostnames` with your name. Example `karimarous`

7. Create a file named `gateway.yaml` in the folder `manifests` that exists under `kubernetes` folder in the root directory and copy the following code 
```bash
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: public-gateway
  namespace: envoy-gateway-system
spec:
  gatewayClassName: gc-gateway-class
  infrastructure:
    parametersRef:
      group: gateway.envoyproxy.io
      kind: EnvoyProxy
      name: ep-envoy-proxy
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: All
  - name: prometheus-https
    hostname: yourfullname-prometheus.aks.karimarous.com
    port: 443
    protocol: HTTPS
    tls:
      mode: Terminate
      certificateRefs:
      - kind: Secret
        name: prometheus-tls
    allowedRoutes:
      namespaces:
        from: All
  - name: grafana-https
    hostname: yourfullname-grafana.aks.karimarous.com
    port: 443
    protocol: HTTPS
    tls:
      mode: Terminate
      certificateRefs:
      - kind: Secret
        name: grafana-tls
    allowedRoutes:
      namespaces:
        from: All
```

Replace your `yourfullname` in both `hostname` with your name. Example `karimarous`

8. Create a file named `gateway.tf` in the `root` folder and copy the following code

```bash
resource "kubectl_manifest" "gateway_class" {
  yaml_body  = file("${path.root}/kubernetes/manifests/gateway-class.yaml")
  depends_on = [kubectl_manifest.envoy_proxy, kubectl_manifest.certificate_grafana, kubectl_manifest.certificate_prometheus]
}

resource "kubectl_manifest" "gateway" {
  yaml_body  = file("${path.root}/kubernetes/manifests/gateway.yaml")
  depends_on = [kubectl_manifest.http_route_kubeflow_pipelines, kubectl_manifest.gateway_class]
}

resource "kubectl_manifest" "http_route_grafana" {
  yaml_body  = file("${path.root}/kubernetes/manifests/grafana-httproute.yaml")
  depends_on = [kubectl_manifest.gateway]
}

resource "kubectl_manifest" "http_route_prometheus" {
  yaml_body  = file("${path.root}/kubernetes/manifests/prometheus-httproute.yaml")
  depends_on = [kubectl_manifest.gateway]
}
```

9. Push to Github repo `aks-tools`

## Install tools

1. In your github repository, click on `Actions`

2. In the left panel, click on `Install tools`, click on `Run workflow`, choose `dev` workspace, fill the field `cluster_name` with your own cluster name. Click on `Run workflow` under them.
3. Go to AWS Route53 in AWS console
4. On the left panel, click on `Hosted zones` and click on `karimarous.com` Hosted Zone Name
5. Click on `Create record`
6. fill the following with:
- `Record name` with  yourfullname.aks (don't forget to update `yourfullname` with your full name, example `karimarous`)
- Click on `Alias`, click on `Choose Endpoint` drop down and choose `Alias to Application and Classic Load Balancer`. Click on `Choose region`, search for `us-east-1` and choose it. Click on `Choose Load Balancer` and choose the load balancer created.
7. Click on `Create records`
8. Wait `10 minutes` and copy the following url in a `Chrome new tab` (don't forget to update `yourfullname` with your full name, example karimarous)
```bash
yourfullname-grafana.aks.karimarous.com
```

### Step 3: desinstall tools 

1. In your github repository, click on `Actions`

2. In the left panel, click on `Desinstall tools`, click on `Run workflow`, choose `dev` workspace fill the field `cluster_name` with your own cluster name. Click on `Run workflow` under them.
