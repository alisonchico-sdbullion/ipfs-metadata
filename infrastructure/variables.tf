variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "docker_image" {
  type        = string
  description = "The docker image contained in a docker repository"
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