terraform{
required_providers{
    aws = {
         source  = "hashicorp/aws"
      version = "~> 5.0"
    }
}
}
provider "aws"{
    region = "ap-southeast-2"
}
resource "aws_security_group" "web_sg" {
  name = "jenkins-terraform-sg"

  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "dockerdemo"{
     ami = "ami-0a59248a6294cece2"  
     instance_type = "t3.micro"
     key_name = "newdemo"
     vpc_security_group_ids = [aws_security_group.web_sg.id]
  tags ={
    Name = "dockerdemo"
  }
}

resource "local_file" "inventory"{
    content = <<EOF
    [webservers]
    ${aws_instance.dockerdemo.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/newdemo.pem  ansible_ssh_extra_args="-o StrictHostKeyChecking=no"
EOF
    filename = "../Ansible/inventory.ini"
}


