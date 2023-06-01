data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

data "aws_vpc" "default" {
  default = true  
}

resource "aws_instance" "blog" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = var.instance_type
  
  vpc_security_group_ids = [module.blog_security_group.security_group_id]
  
  tags = {
    name = "HelloWorld"
  }
}

module "blog_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.2"
  name    = "blog_new" 
  
  vpc_id = data.aws_vpc.default.id
  
  ingress_rules        = ["http_80_tcp,https_443_tcp"]
  ingress_cidr_blocks  = ["0.0.0.0/0"]
  
  engress_rules        = ["all-all"]
  engress_cidr_blocks  = ["0.0.0.0/0"]
  
  http-80-tcp   = [80, 80, "tcp", "HTTP"]
  https-443-tcp  = [443, 443, "tcp", "HTTPS"]
}


resource "aws_security_group" "blog" {
  name        = "blog"
  description = "Allow HTTP and HTTPS, and everything"
  tags = {
    Terraform = "true"
  }
  
  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "blog_http_in" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  
  security_group_id = aws_security_group.blog.id
}

resource "aws_security_group_rule" "blog_https_in" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  
  security_group_id = aws_security_group.blog.id
}

resource "aws_security_group_rule" "blog_everything_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  
  security_group_id = aws_security_group.blog.id
}
