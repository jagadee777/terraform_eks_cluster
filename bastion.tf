provider "aws" {
  access_key = ""
  secret_key = ""
  region     = "us-east-1"
}

data "aws_vpc" "selected" {
  filter {
    name = "tag:Name"
    values = ["terraform-vpc"]
  }
}

resource "aws_subnet" "public-sub" {
  vpc_id = "${data.aws_vpc.selected.id}"
  cidr_block = "172.31.96.0/20"
  map_public_ip_on_launch = true
}


resource "aws_instance" "bastion" {
  ami             = "ami-0c2b8ca1dad447f8a"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public-sub.id
  security_groups = ["${aws_security_group.jenkins-security-group.id}"]
  key_name        = "${aws_key_pair.devops.id}"
  tags = {
    Name = "jenkins"
  }
}
output "jenkins_endpoint" {
  value = formatlist("/var/lib/jenkins/secrets/initialAdminPassword")
}
resource "aws_security_group" "jenkins-security-group" {
  name        = "jenkins-security-group"
  description = "Allow SSH inbound traffic"
  vpc_id      = "${data.aws_vpc.selected.id}"

  ingress {
    # SSH Port 22 allowed from any IP
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    # SSH Port 8080 allowed from any IP
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
      # SSH Port 80 allowed from any IP
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

resource "aws_key_pair" "devops" {
  key_name   = "devops-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnmcYGZXBHpPlQ9cuGXw3xw+m9/+YnSvWYyVA3r5VVgqm5erlPqcNd/fYNro7vfr+QhV/T9WsIyp5BcJu24m6QnvTeHHXj2u7u0Ef61hqZCWOF7i173EvCnXx7JzuWF4fnJFaljHH7Xd0fybO+tH1gPi4ffTjokafDN1WLFJDaL9IAQlXdA7JfjSZ3PqOPdJ0JgzZLtWEbyKcxXM43opeyyhom/T5SQGGfvV54BHvhEfu32ck6iuztKwnscEeHHh4H63Eeni3sxUzyiHz1Gaz8i9vVfCff44GJhJp/SgstS0ECx8NNxuBJXU0o7W8P/jQDmiQyktn4jTiI2I1Y/4ys9dhyiStR0JjkHe37S3hieFhmKNpUGsveOqtL52EecyacY6967lq4+1f34QKKKPGG8N/3wA3eS9V30N9xZx3/Ppgu686L5LdwKnYgxhgDLJPCKRm30rOERD9Oxb5Z4DBeECNHXTt/44yePKvwDE8/UE7TVGf7BRSDffhUu2zxx90= jagad@LAPTOP-3FVSH766"
}
