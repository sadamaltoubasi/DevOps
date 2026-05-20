output "RDSEndpoint" {
  description = "RDS Endpoint"
  value       = aws_db_instance.vprofile-rds.endpoint

}

output "memcachedEndpoint" {
  description = "memcache Endpoint"
  value       = aws_elasticache_cluster.vprofile-cache.configuration_endpoint

}