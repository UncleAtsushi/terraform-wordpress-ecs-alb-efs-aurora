# ALB
resource "aws_lb" "lb" {
  name               = "${var.param.env}-${var.param.sysname}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_lb.id]
  subnets = [
    aws_subnet.public_subnet["01"].id,
    aws_subnet.public_subnet["02"].id
  ]
  enable_deletion_protection = false
  tags = {
    "Name" = "${var.param.env}-${var.param.sysname}-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "target_group" {
  name        = "${var.param.env}-${var.param.sysname}-target-group"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  health_check {
    enabled = true
    path    = "/var/www/html/"
    matcher = "200-302"
  }
}

# Listener
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

}