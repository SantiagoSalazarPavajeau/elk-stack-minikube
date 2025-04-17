terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }

  required_version = ">= 1.3.0"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

locals {
  elastic_version = "7.17.3"
}

resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = local.elastic_version
  namespace  = "default"

  timeout = 600
  wait    = true

  values = [
    file("${path.module}/elasticsearch-values.yaml")
  ]

}

resource "helm_release" "kibana" {
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  version    = local.elastic_version
  namespace  = "default"
  timeout = 600
  wait    = true
  set {
    name  = "elasticsearchHosts"
    value = "http://elasticsearch-master:9200"
  }
  values = [
    file("${path.module}/kibana-values.yaml")
  ]
}

resource "helm_release" "logstash" {
  name       = "logstash"
  repository = "https://helm.elastic.co"
  chart      = "logstash"
  version    = local.elastic_version
  namespace  = "default"
  timeout = 600
  wait    = true
  set {
    name  = "logstashPipeline.logstash\\.conf"
    value = file("${path.module}/../logstash/pipelines/logstash.conf")
  }
  values = [
    file("${path.module}/logstash-values.yaml")
  ]
}

