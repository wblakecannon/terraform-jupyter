provider "aws" {
  region  = "us-west-2"
  profile = "caprinomics"
}

data "aws_ami" "al2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "key-${uuid()}"
  public_key = "${tls_private_key.key.public_key_openssh}"
}

resource "local_file" "pem" {
  filename        = "${aws_key_pair.generated_key.key_name}.pem"
  content         = "${tls_private_key.key.private_key_pem}"
  file_permission = "400"
}

resource "aws_security_group" "jupyter" {
  name        = "${var.service}-${uuid()}"
  description = "Security group for ${title(var.service)}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  ingress {
    from_port   = 8888
    to_port     = 8898
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "${title(var.service)}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Contact     = "${var.contact}"
    Environment = "${title(var.environment)}"
    Name        = "${var.service}-${uuid()}"
    Service     = "${title(var.service)}"
    Terraform   = "true"
  }
}

resource "aws_instance" "jupyter" {
  ami                    = "${data.aws_ami.al2.id}"
  availability_zone      = "${var.availability_zone}"
  instance_type          = "${var.instance_type}"
  key_name               = "${aws_key_pair.generated_key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.jupyter.id}"]
  user_data              = "${file("script.sh")}"

  tags = {
    Name        = "${title(var.service)}-${timestamp()}"
    Service     = "${title(var.service)}"
    Contact     = "${var.contact}"
    Environment = "${title(lower(var.environment))}"
    Terraform   = "true"
  }

  volume_tags = {
    Name        = "${title(var.service)}-${timestamp()}_ROOT"
    Service     = "${title(var.service)}"
    Contact     = "${var.contact}"
    Environment = "${title(lower(var.environment))}"
    Terraform   = "true"
  }
}

resource "aws_ebs_volume" "jupyter" {
  availability_zone = "${var.availability_zone}"
  size              = 8
  type              = "gp2"

  tags = {
    Name        = "${title(var.service)}-${timestamp()}_Anaconda3"
    Service     = "${var.service}"
    Contact     = "${var.contact}"
    Environment = "${title(lower(var.environment))}"
    Terraform   = "true"
  }
}

resource "aws_volume_attachment" "jupyter" {
  device_name  = "/dev/sdb"
  instance_id  = "${aws_instance.jupyter.id}"
  volume_id    = "${aws_ebs_volume.jupyter.id}"
  force_detach = true
}

terraform {
  backend "local" {
  }
}
