module "aks" {
  source  = "Azure/aks/azurerm"
  version = "1.0.0"

  CLIENT_ID                   = "${var.CLIENT_ID}"
  CLIENT_SECRET               = "${var.CLIENT_SECRET}"
  prefix                      = "${var.prefix}"
  location                    = "${var.location}"
  admin_username              = "${var.admin_username}"
  agents_size                 = "${var.agents_size}"
  log_analytics_workspace_sku = "${var.log_analytics_workspace_sku}"
  log_retention_in_days       = "${var.log_retention_in_days}"
  agents_count                = "${var.agents_count}"
  kubernetes_version          = "${var.kubernetes_version}"
  public_ssh_key              = "${var.public_ssh_key}"
}
