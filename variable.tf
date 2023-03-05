variable "param" {
  default = {
    env        = "dev"
    sysname    = "ecswp"
    region     = "us-east-1"
    cidr_block = "10.0.0.0/16"
    zone = {
      "01" = {
        az            = "us-east-1a"
        public_cidr   = "10.0.1.0/24"
        private_cidr  = "10.0.10.0/24"
        database_cidr = "10.0.100.0/24"
      }
      "02" = {
        az            = "us-east-1c"
        public_cidr   = "10.0.2.0/24"
        private_cidr  = "10.0.20.0/24"
        database_cidr = "10.0.200.0/24"
      }
    }
  }
}

variable "db_master_user" {}
variable "db_master_password" {}
