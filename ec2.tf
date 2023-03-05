# resource "aws_instance" "ec2" {
#   ami                         = "ami-006dcf34c09e50022"
#   instance_type               = "t2.micro"
#   associate_public_ip_address = true
#   security_groups             = [aws_security_group.sg_ecs.id]
#   subnet_id                   = aws_subnet.public_subnet["01"].id
#   iam_instance_profile        = aws_iam_instance_profile.instance_profile.name
#   tags = {
#     "Name" = "${var.param.env}-${var.param.sysname}-ec2"
#   }
# }

# resource "aws_iam_role" "ec2_role" {
#   name = "${var.param.env}-${var.param.sysname}-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       },
#     ]
#   })
#   managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
# }

# resource "aws_iam_instance_profile" "instance_profile" {
#   name = "${var.param.env}-${var.param.sysname}-instance-profile"
#   role = aws_iam_role.ec2_role.name
# }
