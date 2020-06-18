terraform {
  required_version = ">=0.12.6"

  backend "remote" {
    organization = "Roleypoly"

    workspaces {
      prefix = "roleypoly-app-"
    }
  }
}
