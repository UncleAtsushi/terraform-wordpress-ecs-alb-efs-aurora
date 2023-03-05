# ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.param.env}-${var.param.sysname}-ecs-cluster"
  tags = {
    "Name" = "${var.param.env}-${var.param.sysname}-ecs-cluster"
  }
}

# Capacity Provider
resource "aws_ecs_cluster_capacity_providers" "capacity_providers" {
  cluster_name       = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy {
    base              = 2
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# Task Role
resource "aws_iam_role" "task_role" {
  name = "${var.param.env}-${var.param.sysname}-task-definition-role"
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
  ]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Task Definition
resource "aws_ecs_task_definition" "task_difinition" {
  # Task Difinition Setting
  family                   = "${var.param.env}-${var.param.sysname}-task-difinition"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  network_mode             = "awsvpc"
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  execution_role_arn = "arn:aws:iam::738452829225:role/ecsTaskExecutionRole"
  task_role_arn      = aws_iam_role.task_role.arn

  # Volume Setting
  volume {
    name = "${var.param.env}-${var.param.sysname}-container-storage-efs"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs_file_system.id
      root_directory = "/"
    }
  }

  # Container Setting
  container_definitions = <<CONTAINER_DEFINITION
[
  {
    "cpu": 10,
    "memory": 512,
    "essential": true,
    "environment": [
      {
        "name": "WORDPRESS_DB_USER",
        "value": "${var.db_master_user}"
      },
      {
        "name": "WORDPRESS_DB_HOST",
        "value": "${aws_rds_cluster.rds_cluster.endpoint}"
      },
      {
        "name": "WORDPRESS_DB_PASSWORD",
        "value": "${var.db_master_password}"
      },
      {
        "name": "WORDPRESS_DB_NAME",
        "value": "${aws_rds_cluster.rds_cluster.database_name}"
      }
    ],
    "mountPoints": [
        {
          "containerPath": "/var/www/html/",
          "sourceVolume": "${var.param.env}-${var.param.sysname}-container-storage-efs"
        }
      ],
    "image": "738452829225.dkr.ecr.us-east-1.amazonaws.com/wordpress:latest",
    "name": "some-wordpress",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "ecs",
        "awslogs-group": "/ecs/task/wordpress",
        "awslogs-create-group": "true"
      }
    },
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
CONTAINER_DEFINITION
  depends_on = [
    aws_rds_cluster_instance.cluster_instance["01"],
    aws_rds_cluster_instance.cluster_instance["02"]
  ]
}

# Service Difinition
resource "aws_ecs_service" "ecs_service" {
  name            = "${var.param.env}-${var.param.sysname}-ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_difinition.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  network_configuration {
    subnets = [
      aws_subnet.private_subnet["01"].id,
      aws_subnet.private_subnet["02"].id
    ]
    security_groups  = [aws_security_group.sg_ecs.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "some-wordpress"
    container_port   = 80
  }
  depends_on = [
    aws_lb_listener.listener
  ]
}
