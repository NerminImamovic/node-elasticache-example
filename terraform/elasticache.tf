resource "aws_elasticache_cluster" "elasticache_cluster" {
  cluster_id           = "my-redis-cluster"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  subnet_group_name    = aws_elasticache_subnet_group.elasticache_subnet_group.name
  security_group_ids   = [aws_security_group.elasticache.id]
}

resource "aws_ssm_parameter" "elasticache_endpoint" {
  name  = "/node_elasticache_serverless/elasticache/endpoint"
  type  = "String"
  value = aws_elasticache_cluster.elasticache_cluster.cache_nodes[0].address
}
