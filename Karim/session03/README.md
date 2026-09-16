# EKS tools - Session 03: Install Envoy proxy gateway and Cert-manager

This session covers the installation of envoy proxy and cert-manager using terraform

## Update Terraform with envoy proxy gateway and cert-manager configuration
### Envoy proxy gateway config
1. Create a folder named `kubernetes` in the root directory. Inside the folder `kubernetes`, create folder named `helm`. Inside the folder `helm`, create folder named `envoy-proxy-gateway`
2. Create a file named `values.yaml` in the folder `envoy-proxy-gateway` and copy the following code

```bash
proxy:
  replicaCount: 1
  resources:
    requests:
      cpu: 200m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi
  service:
    type: LoadBalancer
    externalTrafficPolicy: Cluster
hpa:
  enabled: true
  minReplicas: 1
  maxReplicas: 2
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70

gatewayClass:
  create: true
  name: gc-gateway-class
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
```

3. Inside the folder `envoy-proxy-gateway`, create a folder named `manifests`. Create a file named `envoyproxy.yaml` in the folder `manifests` and copy the following code

```bash
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: EnvoyProxy
metadata:
  name: ep-envoy-proxy
  namespace: envoy-gateway-system
spec:
  logging:
    level:
      default: warn
  provider:
    type: Kubernetes
    kubernetes:
      envoyHpa:
        maxReplicas: 5
        metrics:
          - resource:
              name: cpu
              target:
                averageUtilization: 60
                type: Utilization
            type: Resource
        minReplicas: 2
      envoyService:
        type: LoadBalancer
        externalTrafficPolicy: Cluster
      envoyDeployment:
        replicas: 2   
```

### Cert manager config
1. Create a folder named `cert-manager` inside the the folder `helm`. Inside the folder `cert-manager`, create file named `values.yaml`copy the following code

```bash
crds:
  enabled: true
config:
  apiVersion: controller.config.cert-manager.io/v1alpha1
  kind: ControllerConfiguration
  enableGatewayAPI: true
```

2. Inside the folder `cert-manager`, create a folder named `manifests`. Create a file named `cluster-issuer.yaml` in the folder `manifests` and copy the following code

```bash
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory 
    email: karimmaroous@gmail.com
    privateKeySecretRef:
      name: letsencrypt-prod-account-key
    solvers:
    - http01:
        gatewayHTTPRoute:
          parentRefs:
          - group: gateway.networking.k8s.io
            kind: Gateway
            name: public-gateway
            namespace: envoy-gateway-system 
```

### Update Terraform

In the root directory, create a file named `envoy_proxy_gateway.tf` and copy the following code:

```bash
resource "kubernetes_namespace" "envoy_gateway_system" {
  metadata {
    name = "envoy-gateway-system"
  }
}

resource "helm_release" "envoy_proxy_gateway" {
  name       = "epg"
  namespace  = kubernetes_namespace.envoy_gateway_system.metadata[0].name
  chart   = "oci://docker.io/envoyproxy/gateway-helm"
  version    = "1.7.0" 

  values     = [file("${path.root}/kubernetes/helm/envoy-proxy-gateway/values.yaml")]
  depends_on = [kubernetes_namespace.envoy_gateway_system]
}

resource "kubectl_manifest" "envoy_proxy" {
  yaml_body  = file("${path.root}/kubernetes/helm/envoy-proxy-gateway/manifests/envoyproxy.yaml")
  depends_on = [helm_release.envoy_proxy_gateway]
}
```

In the root directory, create a file named `cert-manager.tf` and copy the following code:

```bash
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
```

8. Push to Github repo `eks-tools`

## Install tools

1. In your github repository, click on `Actions`

2. In the left panel, click on `Install tools`, click on `Run workflow`, choose `dev` workspace fill the field `cluster_name` with your own cluster name. Click on `Run workflow` under them.

### Step 3: desinstall tools 

1. In your github repository, click on `Actions`

2. In the left panel, click on `Desinstall tools`, click on `Run workflow`, choose `dev` workspace fill the field `cluster_name` with your own cluster name. Click on `Run workflow` under them.