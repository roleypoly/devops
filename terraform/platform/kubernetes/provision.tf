terraform {
  required_version = ">=0.12.6"

  backend "remote" {
    organization = "Roleypoly"

    workspaces {
      name = "roleypoly-platform-bootstrap"
    }
  }
}

/*
    DigitalOcean
*/
variable "digitalocean_token" { type = string }
provider "digitalocean" {
  version = ">=1.16.0"
  token   = var.digitalocean_token
}
