data "aws_eks_cluster_auth" "ekscluster" {
  name = aws_eks_cluster.ekscluster.name
}

data "aws_eks_cluster" "ekscluster" {
  name = aws_eks_cluster.ekscluster.name
}

#https://projectcalico.docs.tigera.io/getting-started/kubernetes/managed-public-cloud/eks
data "kubectl_file_documents" "calico" {
    content = file("./calico/calico-vxlan.yaml")
}


resource "null_resource" "delete_aws_node_daemonset" {
    depends_on = [
      aws_eks_cluster.ekscluster
    ]
    provisioner "local-exec" {
        command = <<EOF
aws eks update-kubeconfig --name ${aws_eks_cluster.ekscluster.name} --region ${var.region}
kubectl delete daemonset aws-node -n kube-system
EOF
    }
}

resource "kubectl_manifest" "calico" {
    depends_on = [
      aws_eks_cluster.ekscluster, null_resource.delete_aws_node_daemonset
    ]
    for_each  = data.kubectl_file_documents.calico.manifests
    yaml_body = each.value
    wait_for_rollout = true
}

resource "null_resource" "delete_src_dst_check" {
    depends_on = [
      kubectl_manifest.calico
    ]
    provisioner "local-exec" {
        command = <<EOF
aws eks update-kubeconfig --name ${aws_eks_cluster.ekscluster.name} --region ${var.region}
kubectl -n kube-system set env daemonset/calico-node FELIX_AWSSRCDSTCHECK=Disable
kubectl -n kube-system rollout restart daemonset calico-node
EOF
    }
}