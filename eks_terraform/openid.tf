data "tls_certificate" "clustercertificate" {
  url = aws_eks_cluster.ekscluster.identity[0].oidc[0].issuer
}


resource "aws_iam_openid_connect_provider" "eksopenid" {
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.clustercertificate.certificates[0].sha1_fingerprint]
  url = aws_eks_cluster.ekscluster.identity[0].oidc[0].issuer
}