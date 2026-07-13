resource "aws_ssm_parameter" "db_url" {
  name        = "/vprofile/staging/db_url"
  description = "RDS Database JDBC URL Connection String"
  type        = "SecureString"
  value       = "jdbc:mysql://${aws_db_instance.vpro-rds.endpoint}/accounts?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull"
}

resource "aws_ssm_parameter" "db_user" {
  name        = "/vprofile/staging/db_user"
  description = "Database Master Username"
  type        = "SecureString"
  value       = var.dbuser
}

resource "aws_ssm_parameter" "db_pass" {
  name        = "/vprofile/staging/db_pass"
  description = "Database Master Password"
  type        = "SecureString"
  value       = var.dbpass
}

# ======================= RabbitMQ Parameters =======================

resource "aws_ssm_parameter" "rmq_user" {
  name        = "/vprofile/staging/rmq_user"
  description = "RabbitMQ Username"
  type        = "SecureString"
  value       = var.rmq_user
}

resource "aws_ssm_parameter" "rmq_pass" {
  name        = "/vprofile/staging/rmq_pass"
  description = "RabbitMQ Password"
  type        = "SecureString"
  value       = var.rmq_pass
}
