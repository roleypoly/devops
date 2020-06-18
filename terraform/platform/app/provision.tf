terraform {
  required_version = ">=0.12.6"

  backend "remote" {
    organization = "Roleypoly"

    workspaces {
      name = "roleypoly-platform-app"
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

/*
    Terraform Cloud
*/
variable "tfc_token" { type = string }
variable "tfc_email" { type = string }
variable "tfc_oauth_token_id" { type = string }
variable "tfc_webhook_url" { type = string }
provider "tfe" {
  version = ">=0.15.0"
  token   = var.tfc_token
}

/*
    Cloudflare (for tfc vars)
*/
variable "cloudflare_token" { type = string }
variable "cloudflare_email" { type = string }
variable "cloudflare_zone_id" { type = string }
variable "cloudflare_origin_ca_token" { type = string }
