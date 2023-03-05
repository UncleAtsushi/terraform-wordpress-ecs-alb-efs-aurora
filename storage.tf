# EFS File System
resource "aws_efs_file_system" "efs_file_system" {
  tags = {
    "Name" = "${var.param.env}-${var.param.sysname}-efs"
  }
}

# EFS Mount Target
resource "aws_efs_mount_target" "mount_target" {
  for_each        = var.param.zone
  file_system_id  = aws_efs_file_system.efs_file_system.id
  subnet_id       = aws_subnet.private_subnet[each.key].id
  security_groups = [aws_security_group.sg_efs.id]
}
