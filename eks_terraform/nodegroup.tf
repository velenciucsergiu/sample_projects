resource "aws_launch_template" "nodegrouptemplate" {
    name = "${var.cluster_name}_launch_template"
    image_id = var.ami
    
    instance_type = "t3.medium"
    key_name = var.keypairname
    vpc_security_group_ids = [
      aws_security_group.node.id,
      aws_security_group.nodessh.id
    ]
    monitoring {
      enabled = true
    }
    user_data = base64encode(
    <<EOF
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
/etc/eks/bootstrap.sh ${var.cluster_name} \
  --b64-cluster-ca ${aws_eks_cluster.ekscluster.certificate_authority[0].data} \
  --kubelet-extra-args '--max-pods=35' \
  --apiserver-endpoint ${aws_eks_cluster.ekscluster.endpoint} \
  --dns-cluster-ip 10.100.0.10 \
  --use-max-pods false
    EOF
    )

    depends_on = [
      aws_iam_role_policy_attachment.clusterpolicyattachment,
      aws_iam_role_policy_attachment.vpccontrollerattachment,
      aws_iam_role_policy_attachment.nodegroupworkernodes,
      aws_iam_role_policy_attachment.nodegroupcontainerregirtry,
      aws_iam_role_policy_attachment.nodegroupcni, 
      aws_eks_cluster.ekscluster
    ]
}


data "aws_launch_template" "nodegrouptemplate" {
  name = aws_launch_template.nodegrouptemplate.name

  depends_on = [aws_launch_template.nodegrouptemplate]
}

resource "aws_eks_node_group" "nodegroup" {
    cluster_name = var.cluster_name
    node_role_arn = aws_iam_role.noderole.arn
    subnet_ids = var.subnets
    

    scaling_config {
      desired_size = 1
      min_size = 1
      max_size = 3
    }

    launch_template {
        id = data.aws_launch_template.nodegrouptemplate.id
        version = data.aws_launch_template.nodegrouptemplate.latest_version
    }

    depends_on = [
      aws_iam_role_policy_attachment.clusterpolicyattachment,
      aws_iam_role_policy_attachment.vpccontrollerattachment,
      aws_iam_role_policy_attachment.nodegroupworkernodes,
      aws_iam_role_policy_attachment.nodegroupcontainerregirtry,
      aws_iam_role_policy_attachment.nodegroupcni, 
      aws_eks_cluster.ekscluster
    ]

    lifecycle {
      ignore_changes = [scaling_config[0].desired_size]
    }
    
}
