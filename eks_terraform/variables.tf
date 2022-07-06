variable "cluster_name" {
    type = string
}

variable "account" {
    type = string
}

variable "region" {
    type = string
}

variable "subnets" {
   type = list
}

variable "vpc_id" {
    type = string
}

variable "launch_template" {
    type = string
}

variable "ami" {
    type = string
}

variable "keypairname" {
    type = string
}