resource "aws_security_group" "webSg" {
  name   = "web"
  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-sg"
  }
}
resource "aws_instance" "r100c96" {
  ami               = "ami-0a0e5d9c7acc336f1"
  vpc_security_group_ids = [aws_security_group.webSg.id]
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "aws-exam-testing"
  tags = {
    Name = "New-Server"
  }
 
  provisioner "local-exec" {
    command = "sleep 150"
  }


  provisioner "remote-exec" {
    inline = [ "sudo hostnamectl set-hostname cloudEc2" ]
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("./aws-exam-testing.pem")
    }
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.r100c96.public_dns} > inventory"
  }

  provisioner "local-exec" {
    command = "ansible all -m shell -a 'apt update -y; apt install apache2 -y'"
  }
}

output "ip" {
  value = aws_instance.r100c96.public_ip
}

output "publicName" {
  value = aws_instance.r100c96.public_dns
}
