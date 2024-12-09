variable "name" {
  type        = string
  description = "Name of the golang app"
  default     = "ipfs"
}

variable "region" {
  type        = string
  description = "AWS Region where we will deploy"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Environment Name"
  default     = "test"
}

variable "app_port" {
  type        = number
  description = "The port number on which the application inside the container is exposed"
  default     = 8080
}

variable "cpu" {
  type        = number
  description = "Amount of cpu to provision for application container.  Default is .25 vCPU"
  default     = 256
}

variable "memory" {
  type        = number
  description = "Amount of memory to provision for application container.  Default is .512 MB"
  default     = 512
}