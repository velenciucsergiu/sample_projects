resource "helm_release" "metrics_server" {
    depends_on = [
      aws_eks_node_group.nodegroup
    ]
    name = "metrics-server"
    chart = "./charts/metrics_server"
    namespace = "kube-system"
    force_update = true

    set {
        name = "image.repository"
        value = "k8s.gcr.io/metrics-server/metrics-server"
    }

    set {
        name = "image.tag"
        value = "v0.6.1"
    }
}