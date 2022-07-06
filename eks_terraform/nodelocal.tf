resource "helm_release" "node_local_cache" {
    depends_on = [
      aws_eks_node_group.nodegroup
    ]
    name = "nodelocal-cache"
    chart = "./charts/nodelocal_cache"
    namespace = "kube-system"
    force_update = true

    set {
        name = "image.repository"
        value = "registry.k8s.io/dns/k8s-dns-node-cache"
    }

    set {
        name = "image.tag"
        value = "1.21.1"
    }

    set {
        name = "kubedns"
        value = "10.100.0.10"
    }
}