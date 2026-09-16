locals {
  kube_host                   = data.aws_eks_cluster.eks_cluster.endpoint
  kube_cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                       = data.aws_eks_cluster_auth.eks_cluster_auth.token
}