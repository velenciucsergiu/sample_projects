resource "aws_security_group" "cluster" {
  name = "${var.cluster_name}_cluster"
  description = "cluster security group"
  vpc_id = var.vpc_id
  
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "Name" = "${var.cluster_name}_cluster"
  }
}

resource "aws_security_group" "node" {
  name = "${var.cluster_name}_node"
  description = "node security group"
  vpc_id = var.vpc_id

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "Name" = "${var.cluster_name}_node"
  }
}


resource "aws_security_group" "nodessh" {
  name = "${var.cluster_name}_nodessh"
  description = "allow ssh access to node"
  vpc_id = var.vpc_id
}


#rule for cluster SG
resource "aws_security_group_rule" "ingress_node_to_cluster" {
  type = "ingress"
  description = "ingress from  node to cluster api"
  security_group_id = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.node.id
  protocol = "tcp"
  from_port = 443
  to_port = 443
}

resource "aws_security_group_rule" "egress_cluster_to_node" {
  type = "egress"
  description = "egress from cluster to node"
  security_group_id = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.node.id
  protocol = "tcp"
  from_port = 443
  to_port = 443
}

resource "aws_security_group_rule" "egress_cluster_to_kubelet" {
  type = "egress"
  description = "egress from cluster to node kubelet"
  security_group_id = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.node.id
  protocol = "tcp"
  from_port = 10250
  to_port = 10250
}

#rules for node group security group
resource "aws_security_group_rule" "ingress_node_to_node_coredns_tcp" {
  type = "ingress"
  description = "ingress node to node coredns tcp"
  security_group_id = aws_security_group.node.id
  source_security_group_id = aws_security_group.node.id
  protocol = "tcp"
  from_port = 53
  to_port = 53
}

resource "aws_security_group_rule" "ingress_node_to_node_coredns_udp" {
  type = "ingress"
  description = "ingress node to node coredns udp"
  security_group_id = aws_security_group.node.id
  source_security_group_id = aws_security_group.node.id
  protocol = "udp"
  from_port = 53
  to_port = 53
}

resource "aws_security_group_rule" "ingress_cluster_api_to_kubelet" {
  type = "ingress"
  description = "ingress to kubelet from cluster api"
  security_group_id = aws_security_group.node.id
  source_security_group_id = aws_security_group.cluster.id
  protocol = "tcp"
  from_port = 10250
  to_port = 10250
}

resource "aws_security_group_rule" "ingress_cluster_api_to_node" {
  type = "ingress"
  description = "ingress to node from cluster api"
  security_group_id = aws_security_group.node.id
  source_security_group_id = aws_security_group.cluster.id
  protocol = "tcp"
  from_port = 443
  to_port = 443
}

resource "aws_security_group_rule" "egress_ntp_tcp_internet" {
  type = "egress"
  description = "egress ntp/tcp to internet"
  security_group_id = aws_security_group.node.id
  protocol = "tcp"
  from_port = 123
  to_port = 123
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress_node_to_node_udp" {
  type = "egress"
  description = "egress node to node coredns"
  security_group_id = aws_security_group.node.id
  source_security_group_id = aws_security_group.node.id
  from_port = 53
  to_port = 53
  protocol = "udp"
}

resource "aws_security_group_rule" "egress_ntp_udp_internet" {
  type = "egress"
  description = "egress ntp/udp to internet"
  security_group_id = aws_security_group.node.id
  from_port = 123
  to_port = 123
  protocol = "udp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "egress_node_to_node_tcp" {
  type = "egress"
  description = "egress node to node coredns tcp"
  security_group_id = aws_security_group.node.id
  source_security_group_id = aws_security_group.node.id
  from_port = 53
  to_port = 53
  protocol = "tcp"
}

resource "aws_security_group_rule" "egress_node_to_cluster_tcp" {
  type = "egress"
  description = "egress node to cluster"
  security_group_id = aws_security_group.node.id
  source_security_group_id = aws_security_group.cluster.id
  from_port = 443
  to_port = 443
  protocol = "tcp"
}

resource "aws_security_group_rule" "egress_node_to_internet_https" {
  type = "egress"
  description = "egress node to internet https only"
  security_group_id = aws_security_group.node.id
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}