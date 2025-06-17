variable "db_username" {
  default = "admin"
}

variable "db_password" {
  sensitive   = true
  default = "Sql#1234"
}
