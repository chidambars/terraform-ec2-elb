provider "aws" {
  region  = "us-east-2"
  #profile = "training"
}

resource "aws_instance" "test" {
  count         = var.webserver_count
  ami           = var.ami_id # Ubuntu
  instance_type = "t2.micro"
  user_data     = <<-EOF
              #!/bin/bash
              echo "Hello, World - "`hostname` > index.html
              nohup busybox httpd -f -p 80 &
              EOF
  # = [ aws_security_group.sg.id ]
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = "chidambar-key"
  subnet_id              = var.public_subnet_ids[count.index]
  tags = {
    "Name" = "webserver-chidambar-${count.index + 1}"
  }
  # provisioner "file" {
  #   source      = "listing.sh"
  #   destination = "/tmp/listing.sh"
  #   connection {
  #     type        = "ssh"
  #     user        = "ubuntu"
  #     private_key = file("/Users/mandeepmehra/Downloads/mandeep_key.pem")
  #     host        = self.public_ip
  #   }
  # }

  provisioner "local-exec" {
    # when = destroy
    command = "echo  ${self.private_ip} > ipaddress.txt"
  }

  # provisioner "remote-exec" {
  #   inline = [
  #     "chmod +x  /tmp/listing.sh",
  #     "/tmp/listing.sh"
  #   ]
  #   connection {
  #     type        = "ssh"
  #     user        = "ubuntu"
  #     private_key = file("/Users/mandeepmehra/Downloads/mandeep_key.pem")
  #     host        = self.public_ip
  #   }
  # }
}

resource "aws_security_group" "sg" {
  name   = "tfex-chidu"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "ipaddress" {
  value = aws_instance.test[*].public_ip
}


