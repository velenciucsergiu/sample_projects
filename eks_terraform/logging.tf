resource "helm_release" "logging" {
    depends_on = [
      aws_eks_node_group.nodegroup
    ]
    name = "logging"
    chart = "./charts/logging"
    namespace = "amazon-cloudwatch"
    create_namespace = true
    force_update = true

    set {
        name  = "image.cwagent.name"
        value = "amazon/cloudwatch-agent"
    }

    set {
        name  = "image.cwagent.tag"
        value = "1.247352.0b251908"
    }

    set {
        name  = "cluster_name"
        value = var.cluster_name
    }

    set {
        name = "image.fluentbit.name"
        value = "public.ecr.aws/aws-observability/aws-for-fluent-bit"
    }

    set {
        name = "image.fluentbit.tag"
        value = "stable"
    }

    set {
        name = "roles.cwagent_arn"
        value = aws_iam_role.cloudwatchagent.arn
    }

    set {
        name = "roles.fluent_bit_arn"
        value = aws_iam_role.fluentbit.arn
    }

    set {
        name = "region"
        value = var.region
    }
}