resource "aws_eks_cluster" "ekscluster" {
  name = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version = "1.21"

  vpc_config {
    subnet_ids = var.subnets
    endpoint_public_access = true
    endpoint_private_access = true
    security_group_ids = [aws_security_group.cluster.id]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  depends_on = [
    aws_iam_role_policy_attachment.clusterpolicyattachment,
    aws_iam_role_policy_attachment.vpccontrollerattachment,
    aws_cloudwatch_log_group.cluster_logs,
    aws_security_group.node,
    aws_security_group.cluster
  ]
}