# 1. حفظ رابط الـ Endpoint الخاص بقاعدة البيانات (تم جلبه ديناميكياً)
resource "aws_ssm_parameter" "db_url" {
  name        = "/vprofile/staging/db_url"
  description = "RDS Database JDBC URL Connection String"
  type        = "SecureString"
  value       = "jdbc:mysql://${aws_db_instance.vpro-rds.endpoint}/accounts?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull"
}

# 2. حفظ اسم المستخدم
resource "aws_ssm_parameter" "db_user" {
  name        = "/vprofile/staging/db_user"
  description = "Database Master Username"
  type        = "SecureString"
  value       = var.dbuser
}

# 3. حفظ كلمة المرور
resource "aws_ssm_parameter" "db_pass" {
  name        = "/vprofile/staging/db_pass"
  description = "Database Master Password"
  type        = "SecureString"
  value       = var.dbpass
}