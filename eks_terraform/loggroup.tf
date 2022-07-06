resource "aws_cloudwatch_log_group" "cluster_logs" {
  name = "/aws/eks/cluster/${var.cluster_name}"
  retention_in_days = 7
}