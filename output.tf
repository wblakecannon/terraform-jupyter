output "conn" {
  value = "ssh -i \"${aws_key_pair.generated_key.key_name}.pem\" ec2-user@${aws_instance.jupyter.public_dns}"
}
