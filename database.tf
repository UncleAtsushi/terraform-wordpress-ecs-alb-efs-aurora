# Database Subnet
resource "aws_db_subnet_group" "db_subnet" {
  name       = "${var.param.env}- ${var.param.sysname}-db-subnet"
  subnet_ids = [
    aws_subnet.database_subnet["01"].id,
    aws_subnet.database_subnet["02"].id
  ]
}

# Aurora Cluster
resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier     = "${var.param.env}-${var.param.sysname}-aurora-cluster"
  engine                 = "aurora-mysql"
  engine_version         = "5.7.mysql_aurora.2.11.1"
  availability_zones     = [var.param.zone["01"].az, var.param.zone["02"].az]
  database_name          = "wordpress"
  master_username        = var.db_master_user
  master_password        = var.db_master_password
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids = [aws_security_group.sg_db.id]
  lifecycle {
    ignore_changes = [
      "availability_zones"
    ]
  }
}

# Aurora Cluster Instance
resource "aws_rds_cluster_instance" "cluster_instance" {
  for_each           = var.param.zone
  cluster_identifier = aws_rds_cluster.rds_cluster.id
  identifier         = "${var.param.env}-${var.param.sysname}-aurora-cluster-instance-${each.key}"
  instance_class     = "db.t2.small"
  engine             = aws_rds_cluster.rds_cluster.engine
  engine_version     = aws_rds_cluster.rds_cluster.engine_version
}
