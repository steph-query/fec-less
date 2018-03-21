provider "aws" {
  region = "us-west-2"
}

################
# RDS Instance #
################
resource "aws_db_instance" "swingleft_default" {
  depends_on             = ["aws_security_group.swingleft_default"]
  identifier             = "${var.identifier}"
  allocated_storage      = "${var.storage}"
  engine                 = "${var.engine}"
  engine_version         = "${lookup(var.engine_version, var.engine)}"
  instance_class         = "${var.instance_class}"
  name                   = "${var.db_name}"
  username               = "${var.username}"
  password               = "${var.password}"
  vpc_security_group_ids = ["${aws_security_group.swingleft_default.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.swingleft_default.id}"
  publicly_accessible    = "true"
  skip_final_snapshot    = "true"
}

resource "aws_db_subnet_group" "swingleft_default" {
  name        = "swingleft_subnet_group"
  description = "Subnet group for swingleft stuff"
  subnet_ids  = ["${aws_subnet.subnet_1.id}", "${aws_subnet.subnet_2.id}"]
}

###########
# Subnets #
###########
resource "aws_subnet" "subnet_1" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${var.subnet_1_cidr}"
  availability_zone       = "${var.az_1}"
  map_public_ip_on_launch = "true"

  tags {
    Name = "swingleft_private_subnet"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${var.subnet_2_cidr}"
  availability_zone       = "${var.az_2}"
  map_public_ip_on_launch = "true"

  tags {
    Name = "swingleft_public_subnet"
  }
}

###################
# Security Groups #
###################
resource "aws_security_group" "swingleft_default" {
  name        = "swingleft_rds_sg"
  description = "Allow all inbound traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "TCP"
    cidr_blocks = ["${var.cidr_blocks}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.sg_name}"
  }
}

##########
## Vars ##
##########
variable "identifier" {
  default     = "swingleft-fec-rds"
  description = "Identifier for your DB"
}

variable "storage" {
  default     = "10"
  description = "Storage size in GB"
}

variable "engine" {
  default     = "postgres"
  description = "Engine type, example values mysql, postgres"
}

variable "engine_version" {
  description = "Engine version"

  default = {
    mysql    = "5.6.22"
    postgres = "9.6.6"
  }
}

variable "instance_class" {
  default     = "db.t2.micro"
  description = "Instance class"
}

variable "db_name" {
  default     = "swingleftfec"
  description = "db name"
}

variable "username" {
  default     = "swingleft"
  description = "User name"
}

variable "password" {
  description = "password, provide through your ENV variables"
}

## Subnet Vars ##
variable "subnet_1_cidr" {
  default     = "172.31.64.0/27"
  description = "private subnet cidr"
}

variable "subnet_2_cidr" {
  default     = "172.31.96.0/27"
  description = "public subnet cidr"
}

variable "az_1" {
  default     = "us-west-2b"
  description = "availability zone 1"
}

variable "az_2" {
  default     = "us-west-2c"
  description = "availability zone 2"
}

variable "vpc_id" {
  default     = "vpc-8dab51e9"
  description = "VPC ID"
}

## SG Vars ##
variable "cidr_blocks" {
  default     = "76.102.127.36/32"
  description = "CIDR for sg"
}

variable "sg_name" {
  default     = "swingleft_rds"
  description = "Tag Name for sg"
}

###########
# Outputs #
###########
output "subnet_group" {
  value = "${aws_db_subnet_group.swingleft_default.name}"
}

output "db_instance_id" {
  value = "${aws_db_instance.swingleft_default.id}"
}

output "db_instance_address" {
  value = "${aws_db_instance.swingleft_default.address}"
}
