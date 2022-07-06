resource "helm_release" "cluster_autoscaler" {
    depends_on = [
      aws_eks_node_group.nodegroup
    ]
    name = "cluster-autoscaler"
    chart = "./charts/cluster_autoscaler"

    set {
        name = "image.repository"
        value = "k8s.gcr.io/autoscaling/cluster-autoscaler"
    }

    set {
        name = "image.tag"
        value = "v1.22.2"
    }

    set {
        name = "autoscaler_role"
        value = aws_iam_role.cluster_autoscaler.arn
    }

    set {
        name = "cluster_name"
        value = var.cluster_name
    }
}