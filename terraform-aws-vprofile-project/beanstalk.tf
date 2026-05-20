# 1. إنشاء الـ Beanstalk Application
resource "aws_elastic_beanstalk_application" "vprofile_app" {
  name        = "vprofile-app"
  description = "vProfile Application managed by Terraform"
}

# 2. إنشاء الـ Beanstalk Environment وتطبيق شروطك بدقة
resource "aws_elastic_beanstalk_environment" "vprofile_env" {
  name        = "vprofile-env"
  application = aws_elastic_beanstalk_application.vprofile_app.name

  # الحل الافتراضي (Solution Stack) المطلوبة منك لـ Tomcat 10
  solution_stack_name = "64bit Amazon Linux 2023 v5.11.0 running Tomcat 10 Corretto 21"
  tier                = "WebServer"

  # =========================================================================
  # إعدادات الشبكة (VPC & Subnets)
  # =========================================================================

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = module.vpc.vpc_id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "false" # السيرفرات في الـ Private لا تحتاج IP عام مباشر
  }

  # شرطك: الـ EC2 Instances يجب أن تكون في الـ Private Subnets
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", module.vpc.private_subnets)
  }

  # شرطك: الـ Load Balancer يجب أن يمر بالـ Public Subnets
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", module.vpc.public_subnets)
  }

  # =========================================================================
  # إعدادات السيرفرات والأمان (EC2 & KeyPair & Security Groups)
  # =========================================================================

  # شرطك: استخدام نوع السيرفر t2.medium
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.medium"
  }

  # شرطك: استخدام الـ Key Pair المسمى vprofilekey
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = aws_key_pair.vprofilekey.key_name
  }

  # شرطك: ربط الـ Security Group الخاص بالـ EC2 (bean-ec2-sg)
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.bean-ec2-sg.id
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "aws-elasticbeanstalk-ec2-role" # الـ Role الافتراضي لـ AWS Beanstalk
  }

  # =========================================================================
  # إعدادات الـ Load Balancer والتوسيع التلقائي (Autoscaling من 2 إلى 4)
  # =========================================================================

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application" # استخدام Application Load Balancer
  }

  # شرطك: ربط الـ Security Group الخاص بالـ Load Balancer (vprofile-bean-elb-sg)
  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "SecurityGroups"
    value     = aws_security_group.vprofile-bean-elb-sg.id
  }

  # شرطك: الحد الأدنى للسيرفرات هو 2
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "2"
  }

  # شرطك: الحد الأقصى للسيرفرات هو 4
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "4"
  }

  tags = {
    ManagedBy = "Terraform"
    Project   = "vProfile"
  }
}