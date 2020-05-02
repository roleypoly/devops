variable "deployment_env" {
    type = map(map(map(string)))
}

variable "env_tag" {
    type = string
    description = "One of: production, staging, test"
}