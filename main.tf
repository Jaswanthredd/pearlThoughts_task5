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
                # Update the system
                apt-get update -y

                # Install Node.js
                curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
                apt-get install -y nodejs

                # Install Yarn
                npm install --global yarn

                # Install Medusa CLI
                yarn global add @medusajs/medusa-cli

                # Create a directory for Medusa and navigate to it
                mkdir /home/ubuntu/medusa
                cd /home/ubuntu/medusa

                # Initialize a new Medusa project
                medusa new .

                # Install project dependencies
                yarn install

                # Start the Medusa server
                yarn start
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
