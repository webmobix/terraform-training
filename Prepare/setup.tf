# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.7.0"
    }
  }
  required_version = ">= 0.14.9"
}
provider "azurerm" {
  features {}
  subscription_id = "6a90b907-4713-481e-b7f5-ef56698a4a08"
}

variable "student_principal_name" {
  type = string
  default = "tutor"
}

data "azuread_client_config" "current" {}

# Generate a random integer to create a globally unique name
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

# Create the resource group
resource "azurerm_resource_group" "rg" {
  name     = "azure-terraform-learning-oct24-${random_integer.ri.result}"
  location = "germanywestcentral"
}

# Create the Linux App Service Plan
# resource "azurerm_service_plan" "appserviceplan" {
#   name                = "webapp-asp-${random_integer.ri.result}"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   os_type             = "Linux"
#   sku_name            = "B1" // F1 - Free S1 - Shared
# }

resource "time_rotating" "example" {
  rotation_days = 4
}

# Create the Service Principal
resource "azuread_application" "student_app" {
  display_name = "${var.student_principal_name}-app"
  owners       = [data.azuread_client_config.current.object_id]

  password {
    display_name = "tutor-secret"
    start_date   = time_rotating.example.id
    end_date     = timeadd(time_rotating.example.id, "96h")
  }
}

output "tutor_password" {
  sensitive = true
  value     = tolist(azuread_application.student_app.password).0.value
}

output "client_id" {
  value = azuread_application.student_app.client_id
}

data "azurerm_subscription" "current" {
}

output "tenant_id" {
  value = data.azurerm_subscription.current.tenant_id
}
output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}

resource "azuread_service_principal" "student_sp" {
  client_id      = azuread_application.student_app.client_id
  app_role_assignment_required = false
  owners         = [data.azuread_client_config.current.object_id]
}

# Assign Contributor Role to the Service Principal at Resource Group level
resource "azurerm_role_assignment" "student_contributor" {
  principal_id   = azuread_service_principal.student_sp.object_id
  role_definition_name = "Contributor"
  scope          = azurerm_resource_group.rg.id
}

resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "acctest-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "app_env" {
  name                       = "Leaning-Environment"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics.id
}
