# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.103.1"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Configure the GitHub Provider
provider "github" {
}

resource "github_repository" "Azure-Hub-spoke-connectivity" {
  name        = "Azure-Hub-spoke-connectivity"
  description = "Azure-Hub-spoke-connectivity"
  visibility  = "public"
}
