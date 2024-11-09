# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.7.0"
    }
  }
  required_version = ">= 1.1.0"
}

variable "client_secret" { type = string }

provider "azurerm" {
   features {}

  client_id       = "d09fbf1e-0820-4ae3-a6b7-5a3012e44e4e"
  client_secret   = var.client_secret
  tenant_id       = "3bf0542a-afe6-44a3-9078-c418aa3815a3"
  subscription_id = "6a90b907-4713-481e-b7f5-ef56698a4a08"
}

# Load the existing Resource Group by name
data "azurerm_resource_group" "rg" {
  name = "azure-terraform-learning-oct24-48566"
}

# Load the existing container app environment by name
data "azurerm_container_app_environment" "app_env" {
  name                = "Leaning-Environment"
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Generate a random integer to create a globally unique name
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

# Generate the container app
resource "azurerm_container_app" "hello-world-app" {
  name                         = "hello-world-app-${random_integer.ri.result}"
  container_app_environment_id = data.azurerm_container_app_environment.app_env.id
  resource_group_name          = data.azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "hello-world"
      image  = "docker.io/dannyt74/hello-express:v2"
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name = "SECRET"
        value = "GEHEIMES_PASSWORD"
      }
    }
  }

  ingress {
    target_port = 3000
    external_enabled = true
    traffic_weight {
      latest_revision = true
      percentage = 100
    }
  }
}

output "random_int" {
  value = random_integer.ri.result
}

output "endpoint" {
  value = azurerm_container_app.hello-world-app.ingress[0].fqdn
}
