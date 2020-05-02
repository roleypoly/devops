terraform {
  required_version = ">=0.12.6"

  backend "remote" {
    organization = "Roleypoly"

    workspace {
        prefix = "roleypoly-app-"
    }
  }
}

variable "deployment_env" {
    type = map(map(string))
}

variable "env_tag" {
    type = string
    description = "One of: production, staging, test"
}