terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  version = "=2.0.0"
  features {}
  disable_terraform_partner_id = true
}

data "azurerm_kubernetes_cluster" "sub1" {
  name                = "test-aks"
  resource_group_name = "test-rg"
}

module "bootstrap_app1" {
  source = "./modules/bootstrap"

  app_name = "app1"
  app_path = "manifests/app1"
  metadata_namespace = "default"
  environment = "dev"
  kubeconfig_raw = data.azurerm_kubernetes_cluster.sub1.kube_admin_config_raw
}
