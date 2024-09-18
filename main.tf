provider "aws" {
  region = "us-east-1"  # Set your desired AWS region
}

resource "aws_instance" "medusa_ec2" {
  ami           = "ami-0e86e20dae9224db8"  # Use a valid AMI ID for your region
  instance_type = "t2.small"  # Choose your instance type
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name = "MedusaEC2Instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y docker.io
              sudo systemctl start docker
              sudo docker run -d -p 80:80 medusa_image:latest
              EOF
}

resource "aws_iam_role" "ssm_role" {
  name = "SSMRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com",
        },
        Action = "sts:AssumeRole",
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role     = aws_iam_role.ssm_role.name
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "SSMInstanceProfile"
  role = aws_iam_role.ssm_role.name
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
