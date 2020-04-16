provider "k14s" {
  kapp {
    kubeconfig_yaml = var.kubeconfig_raw
  }
}

data "external" "build" {
  program = ["bash", "${path.module}/build.sh"]
  query = {
     dir = "${abspath(path.root)}/${var.app_path}/overlays/${var.environment}"
  }
}

data "external" "filter" {
  program = ["bash", "${path.module}/filter.sh"]
  query = {
     raw = data.external.build.result.raw
     # usage with vault and startupsecrets
     #namespace = var.bootstrap_namespace
  }
}

data "k14s_ytt" "bootstrap" {
  files = [
    "${abspath(path.root)}/${var.app_path}/bootstrap/init-secrets.yaml",
    "${abspath(path.root)}/${var.app_path}/bootstrap/init-secrets-values.yaml"
  ]

  ignore_unknown_comments = true

  config_yaml = <<EOF
    #@ load("@ytt:overlay", "overlay")
    #@overlay/match by=overlay.not_op(overlay.subset({"kind":"Secret","metadata":{"name":"init-secrets"}})),expects=0
    #@overlay/remove
EOF
}


resource "k14s_kapp" "deploy_namespace" {
  app = var.app_name
  namespace = var.metadata_namespace
  config_yaml = data.external.filter.result.ns
  #diff_changes = true
}

resource "k14s_kapp" "deploy_secrets" {
  app = var.app_name
  namespace = var.metadata_namespace
  config_yaml = data.k14s_ytt.bootstrap.result
  #diff_changes = true
  depends_on = [
     k14s_kapp.deploy_namespace
  ]
}

resource "k14s_kapp" "deploy_rest" {
  app = var.app_name
  namespace = var.metadata_namespace
  config_yaml = data.external.filter.result.other
  #diff_changes = true
  depends_on = [
     k14s_kapp.deploy_secrets
  ]
}
