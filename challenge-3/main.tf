
variable "instance_config" {
  type = map(object({
    instance_type = string
    ami           = string
  }))
  default = {
    instance1 = { instance_type = "t2.micro", ami = "ami-03a6eaae9938c858c" }
    instance2 = { instance_type = "t2.small", ami = "ami-053b0d53c279acc90" }
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

resource "aws_instance" "this" {
  # The map key becomes the instance key; removing a key from `instance_config`
  # removes (destroys) the corresponding EC2 instance on the next `terraform apply`.
  for_each = var.instance_config

  ami           = each.value.ami
  instance_type = each.value.instance_type

  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [data.aws_security_group.default.id]
  associate_public_ip_address = true

  tags = {
    Name = each.key
  }
}

