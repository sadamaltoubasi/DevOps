resource "aws_route53_zone" "private_zone" {
  name = "vpro.internal" 

  vpc {
    vpc_id = module.vpc.vpc_id 
  }
}

resource "aws_route53_record" "rabbitmq_record" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "rmq01.vpro.internal"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.rabbitmq_server.private_ip]

  depends_on = [aws_route53_zone.private_zone]
}

resource "aws_route53_record" "memcached_record" {
  zone_id = aws_route53_zone.private_zone.zone_id
  name    = "mc01.vpro.internal"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.memcached_server.private_ip]

  depends_on = [aws_route53_zone.private_zone]
}

