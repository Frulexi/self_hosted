variable "host_path" {
  type = string 
  default = "/home/afruendly/self_hosted1/data"
  description = "default path to data folder "
}

variable "admin_password" {
  type = string
  description = "admin users password"
  sensitive = true
}

variable "root_password" {
  type = string
  description = "root password"
  sensitive = true
}

variable "admin_user" {
  type = string 
  default = "Falexis"
  description = "value"
}