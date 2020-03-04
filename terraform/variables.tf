variable "environment" {
  type        = string
  description = "Environment name, e.g. 'dev' or 'stage'"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Azure region where to create resources."
  default     = "West Europe"
}

variable "storage_id" {
  type        = string
  description = "Azure region where to create resources."
  default     = "my_unique_identifier"
}

variable "db-login" {
  type        = string
  description = "Login for the SQL server."
  default     = "aialadbadmin"
}

variable "db-pwd" {
  type        = string
  description = "Password for the SQL server."
  default     = "4-v3ry-53cr37-p455w0rd"
}