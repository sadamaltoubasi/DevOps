output "RDSEndpoint" {
  description = "RDS Endpoint"
  value       = aws_db_instance.vpro-rds.endpoint

}

output "alb_dns_name" {
  description = "The DNS name of the Load Balancer"
  value       = aws_lb.app_alb.dns_name
}


output "alb_prod_dns_name" {
  description = "The DNS name of the Load Balancer"
  value       = aws_lb.prod_alb.dns_name
}