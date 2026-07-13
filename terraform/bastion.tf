resource "aws_instance" "bastion-host" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.medium"
  subnet_id                   = module.vpc.public_subnets[1]
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = aws_key_pair.vprotest.key_name
  associate_public_ip_address = true


  tags = {
    Name        = "bastion-host"
    Environment = "dev"
    Terraform   = "true"
  }
}




resource "null_resource" "db_setup" {

  triggers = {
    script_hash = filemd5("template/db-deploy.sh")
  }

  # تعريف طريقة الاتصال بالسيرفر
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("test") # المسار للمفتاح الخاص بك
    host        = aws_instance.bastion-host.public_ip
  }

  # نقل ملف السكريبت من المجلد المحلي إلى السيرفر
  provisioner "file" {
    # دالة templatefile تأخذ ملفك الحالي وتقوم بتبديل المتغيرات التي بداخله
    content = templatefile("${path.module}/template/db-deploy.sh", {
      rds-endpoint = aws_db_instance.vpro-rds.address,
      dbuser       = var.dbuser,
      dbpass       = var.dbpass,
      dbname       = var.dbname
    })
    destination = "/tmp/db-deploy.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/db-deploy.sh",
      "sudo /tmp/db-deploy.sh"
    ]
  }

  # لضمان عدم تنفيذ السكريبت إلا بعد أن يصبح السيرفر جاهزاً
  depends_on = [aws_instance.bastion-host]
}