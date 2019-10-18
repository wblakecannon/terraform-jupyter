output "ip" {
  value = "${aws_instance.jupyter.public_dns}"
}
