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
resource "aws_instance" "dockerdemo"{
     ami = "ami-0a59248a6294cece2"  
  instance_type = "t3.micro"
  key_name = "newdemo"

  tags ={
    Name = "dockerdemo"
  }
}

resource "local_file" "inventory"{
    content = <<EOF
    [webservers]
    ${aws_instance.dockerdemo.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/newdemo.pem
EOF
    filename = "../Ansible/inventory.ini"
}


