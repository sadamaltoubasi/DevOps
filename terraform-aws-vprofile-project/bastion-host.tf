# 1. جلب أحدث نسخة رسمية من نظام Ubuntu 24.04 LTS تلقائياً
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # المعرف الرسمي لشركة Canonical مالكة Ubuntu

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}


# 3. إنشاء سيرفر الـ Bastion Host (EC2 Instance)
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"                   # حجم صغير جداً واقتصادي ومناسب للباستيون
  subnet_id                   = module.vpc.public_subnets[0] # وضعه في أول شبكة عامة أنشأها موديول الـ VPC
  vpc_security_group_ids      = [aws_security_group.bastion-sg.id]
  key_name                    = aws_key_pair.vprofilekey.key_name # استخدام الـ Key Pair الخاص بمشروعك
  associate_public_ip_address = true                              # إعطائه IP عام ليقبل الاتصال من الإنترنت


  # 1. نقل ملف السكريبت إلى السيرفر

  tags = {
    Name      = "vprofile-bastion-host"
    ManagedBy = "Terraform"
    Project   = "vProfile"
  }
}

# 3. استخدام null_resource لتنفيذ السكريبت
resource "null_resource" "db_setup" {

  # التريجر لضمان إعادة التنفيذ عند تغيير السكريبت
  triggers = {
    script_hash = filemd5("template/db-deploy.sh")
  }

  # تعريف طريقة الاتصال بالسيرفر
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("vpro-new-key") # المسار للمفتاح الخاص بك
    host        = aws_instance.bastion.public_ip
  }

  # نقل ملف السكريبت من المجلد المحلي إلى السيرفر
  provisioner "file" {
    # دالة templatefile تأخذ ملفك الحالي وتقوم بتبديل المتغيرات التي بداخله
    content = templatefile("${path.module}/template/db-deploy.sh", {
      rds-endpoint = aws_db_instance.vprofile-rds.address,
      dbuser       = var.dbuser,
      dbpass       = var.dbpass,
      dbname       = var.dbname
    })
    destination = "/tmp/db-deploy.sh"
  }

  # تنفيذ الأوامر داخل السيرفر
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/db-deploy.sh",
      "sudo /tmp/db-deploy.sh"
    ]
  }

  # لضمان عدم تنفيذ السكريبت إلا بعد أن يصبح السيرفر جاهزاً
  depends_on = [aws_instance.bastion]
}

# 4. إخراج الـ IP العام
output "bastion_public_ip" {
  description = "The public IP address of the Bastion Host"
  value       = aws_instance.bastion.public_ip
}