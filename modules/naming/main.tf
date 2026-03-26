# tf-aws-infra-modules/modules/naming/main.tf

module "naming_standard" {
  source = "git::https://github.com/yeongki0944/tf-mzc-naming-standard.git//?ref=v1.0.0"

  customer      = var.customer
  project       = var.project
  environment   = var.environment
  app_name      = var.app_name
  resource_type = var.resource_type
  name          = var.name
}