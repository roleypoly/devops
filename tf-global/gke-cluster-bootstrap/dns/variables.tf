variable "ingress-name" {
  type = string
}

variable "ingress-namespace" {
  type = string
}

variable "ingress-endpoint" {
  type = object({
    ip       = string
    hostname = string
  })
}

variable "cloudflare-zone-id" {
  type = string
}

variable "record-name" {
  type = string
}
