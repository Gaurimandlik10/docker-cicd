output "ec2_public_ip"{
    value = aws_instance.dockerdemo.public_ip
}
