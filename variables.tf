variable "main-resource-group" {
  type = string
}

variable "lb-type" {
  type    = string
  default = "public"
}

variable "cluster-name" {
  type = string
}

variable "environment" {
  type = string
}

variable "name-suffix" {
  type = string
}

variable "lb-ports" {
  type    = map(list(string))
  default = {}
}

variable "lb-probe-interval" {
  type    = string
  default = 5
}

variable "lb-probe-unhealthy-threshold" {
  type    = string
  default = 2
}

variable "subnet-id" {
  type    = string
  default = ""
}

variable "frontend-private-ip-address-allocation" {
  type    = string
  default = "Dynamic"
}

variable "frontend-private-ip-address" {
  type    = string
  default = ""
}
