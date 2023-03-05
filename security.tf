## Security Group(ECS)
resource "aws_security_group" "sg_ecs" {
  name   = "${var.param.env}_${var.param.sysname}_sg_ecs"
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "${var.param.env}_${var.param.sysname}_sg_ecs"
  }
}

## Security Group(EFS)
resource "aws_security_group" "sg_efs" {
  name   = "${var.param.env}_${var.param.sysname}_sg_efs"
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "${var.param.env}_${var.param.sysname}_sg_efs"
  }
}

## Security Group(LB)
resource "aws_security_group" "sg_lb" {
  name   = "${var.param.env}_${var.param.sysname}_sg_lb"
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "${var.param.env}_${var.param.sysname}_sg_lb"
  }
}

## Security Group(Database)
resource "aws_security_group" "sg_db" {
  name   = "${var.param.env}_${var.param.sysname}_sg_db"
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "${var.param.env}_${var.param.sysname}_sg_db"
  }
}

## Ingress Rule(LB)
# Allow HTTP from Anyware
resource "aws_security_group_rule" "sg_rule_lb_ingress_1" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_lb.id
}
## Egress Rule(LB)
# Allow All to Anyware
resource "aws_security_group_rule" "sg_rule_lb_egress_1" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_lb.id
}

## Ingress Rule(ECS)
# Allow HTTP from LB
resource "aws_security_group_rule" "sg_rule_ecs_ingress_1" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_lb.id
  security_group_id        = aws_security_group.sg_ecs.id
}
## Egress Rule(ECS)
# Allow All to Anyware
resource "aws_security_group_rule" "sg_rule_ecs_egress_1" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_ecs.id
}

## Ingress Rule(EFS)
# Allow from ECS
resource "aws_security_group_rule" "sg_rule_efs_ingress_1" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_ecs.id
  security_group_id        = aws_security_group.sg_efs.id
}
## Egress Rule(EFS)
# Allow All to Anyware
resource "aws_security_group_rule" "sg_rule_efs_egress_1" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_efs.id
}

## Ingress Rule(DB)
# Allow MySQL connect from ECS
resource "aws_security_group_rule" "sg_rule_db_ingress_1" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sg_ecs.id
  security_group_id        = aws_security_group.sg_db.id
}
## Egress Rule(DB)
resource "aws_security_group_rule" "sg_rule_db_egress_1" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_db.id
}
