terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 3.20.0"
        }

        kubectl = {
            source  = "gavinbunney/kubectl"
            version = ">= 1.7.0"
        }

        helm = {
            source = "hashicorp/helm"
            version = "2.6.0"
        }
    }
    required_version = "> 1.0.8"
    backend "s3" {

        encrypt = true
    }
}

provider "aws" {
}

provider "kubectl" {
    host                   = data.aws_eks_cluster.ekscluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.ekscluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.ekscluster.token
    load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.ekscluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.ekscluster.certificate_authority[0].data)
    token = data.aws_eks_cluster_auth.ekscluster.token
  }
}