output "public_dns" {
  value = "${aws_instance.jupyter.public_dns}"
}
