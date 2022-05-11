data "aws_ami" "ubuntu" {
  owners = ["099720109477"]

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "deployer-one"
  public_key = tls_private_key.this.public_key_openssh
}

data "template_file" "aws_mgw_init" {
  template = file("${path.module}/scripts/ecs_mesh_gw.sh")
  vars = {
    agent_config = base64decode(var.consul_config_file)
    token = var.boostrap_acl_token
    ca = base64decode(var.consul_ca_file)
    partition = var.env_name
    consul_version = substr(var.consul_version, 1, -1)
  }
}

resource "aws_instance" "mesh_gateway" {
  instance_type               = "t3.small"
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = module.key_pair.key_pair_key_name
  subnet_id                   = var.ecs_dev_public_subnets[0]
  associate_public_ip_address = true
  user_data                   = data.template_file.aws_mgw_init.rendered
  tags = {
    Name = "consul-mgw"
  }
}
