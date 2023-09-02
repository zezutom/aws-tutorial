variable "profile" {
  default     = "default"
  description = "AWS profile"
}

variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

variable "db_username" {
  description = "RDS root user name"
  sensitive   = true
}

variable "db_password" {
  description = "RDS root user password"
  sensitive   = true
}