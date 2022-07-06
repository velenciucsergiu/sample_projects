resource "aws_iam_role" "eks_cluster_role" {
    name = "${var.cluster_name}_cluster_role"
    
    assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}


resource "aws_iam_role_policy_attachment" "clusterpolicyattachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "vpccontrollerattachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role" "noderole" {
    name = "${var.cluster_name}_nodegroup_name"

    assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "nodegroupworkernodes" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.noderole.name
}

resource "aws_iam_role_policy_attachment" "nodegroupcontainerregirtry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.noderole.name
}

resource "aws_iam_role_policy_attachment" "nodegroupcni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.noderole.name
}


resource "aws_iam_role" "cloudwatchagent" {
    name = "${var.cluster_name}_cloudwatch"

    assume_role_policy =  <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action" : "sts:AssumeRoleWithWebIdentity",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.eksopenid.arn}"
      },
      "Condition" : {
        "StringEquals": {
          "${replace(aws_iam_openid_connect_provider.eksopenid.url, "https://", "")}:sub": "system:serviceaccount:amazon-cloudwatch:cloudwatch-agent"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cloudwatchagent" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role = aws_iam_role.cloudwatchagent.name
}

resource "aws_iam_role" "fluentd" {
    name = "${var.cluster_name}_fluentd"

    assume_role_policy =  <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action" : "sts:AssumeRoleWithWebIdentity",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.eksopenid.arn}"
      },
      "Condition" : {
        "StringEquals": {
          "${replace(aws_iam_openid_connect_provider.eksopenid.url, "https://", "")}:sub": "system:serviceaccount:amazon-cloudwatch:fluentd"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "fluentd" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role = aws_iam_role.fluentd.name
}

resource "aws_iam_role" "fluentbit" {
    name = "${var.cluster_name}_fluentbit"

    assume_role_policy =  <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action" : "sts:AssumeRoleWithWebIdentity",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.eksopenid.arn}"
      },
      "Condition" : {
        "StringEquals": {
          "${replace(aws_iam_openid_connect_provider.eksopenid.url, "https://", "")}:sub": "system:serviceaccount:amazon-cloudwatch:fluent-bit"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "fluentbit" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role = aws_iam_role.fluentbit.name
}


resource "aws_iam_role" "cluster_autoscaler" {
    name = "${var.cluster_name}_cluster_autoscaler"

    assume_role_policy =  <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action" : "sts:AssumeRoleWithWebIdentity",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.eksopenid.arn}"
      },
      "Condition" : {
        "StringEquals": {
          "${replace(aws_iam_openid_connect_provider.eksopenid.url, "https://", "")}:sub": "system:serviceaccount:kube-system:cluster-autoscaler"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name        =  "${var.cluster_name}_cluster_autoscaler_policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:ResourceTag/k8s.io/cluster-autoscaler/${var.cluster_name}": "owned"
                }
            }
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeAutoScalingGroups",
                "ec2:DescribeLaunchTemplateVersions",
                "autoscaling:DescribeTags",
                "autoscaling:DescribeLaunchConfigurations"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
  role = aws_iam_role.cluster_autoscaler.name
}