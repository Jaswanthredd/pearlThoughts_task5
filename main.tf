provider "aws" {
  region = "us-east-1"  # Set your desired AWS region
}

resource "aws_instance" "medusa_ec2" {
  ami           = "ami-0e86e20dae9224db8"  # Use a valid AMI ID for your region
  instance_type = "t2.small"  # Choose your instance type

  # If using a key pair for SSH (not used here but may be necessary if you decide to use SSH)
  # key_name = "your-key-name"

  # Configure security group inline
  vpc_security_group_ids = [aws_security_group.medusa_sg.id]

  # User data to set up the instance
  user_data = <<-EOF
                #!/bin/bash
                apt-get update -y
                apt-get install -y docker.io
                systemctl start docker
                docker run -d -p 80:80 medusa_image:latest
                EOF

  tags = {
    Name = "MedusaEC2Instance"
  }
}

resource "aws_security_group" "medusa_sg" {
  name_prefix = "medusa_sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "instance_public_ip" {
  value = aws_instance.medusa_ec2.public_ip
}
