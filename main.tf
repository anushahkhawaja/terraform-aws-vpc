terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}


//creating public vpc

resource "aws_vpc" "my_public_vpc" {

  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = var.resource_tags
}

//creating subnet

resource "aws_subnet" "my_public_subnet" {

  count = length(var.availability_zones)

  vpc_id            = aws_vpc.my_public_vpc.id
  cidr_block        = cidrsubnet(var.subnet_cidr_block, ceil(log(var.max_subnets, 2)), count.index)
  availability_zone = var.availability_zones[count.index]

  tags = var.resource_tags

}

//creating security group

resource "aws_security_group" "my_public_sg" {
  description = "Allow http and https traffic"
  vpc_id      = aws_vpc.my_public_vpc.id
  name        = "my_public_sg"

  tags = var.resource_tags

}

//creating ingress rules
resource "aws_security_group_rule" "my_public_sg_ingress_rules" {
  count             = length(var.ingress_rules)
  type              = "ingress"
  security_group_id = aws_security_group.my_public_sg.id

  cidr_blocks = var.ingress_rules[count.index].cidr_blocks
  description = var.ingress_rules[count.index].description
  from_port   = var.ingress_rules[count.index].from_port
  protocol    = var.ingress_rules[count.index].protocol
  to_port     = var.ingress_rules[count.index].to_port

}

resource "aws_security_group_rule" "my_public_sg_egress_rules" {
  count             = length(var.egress_rules)
  type              = "egress"
  security_group_id = aws_security_group.my_public_sg.id

  cidr_blocks = var.egress_rules[count.index].cidr_blocks
  description = var.egress_rules[count.index].description
  from_port   = var.egress_rules[count.index].from_port
  protocol    = var.egress_rules[count.index].protocol
  to_port     = var.egress_rules[count.index].to_port
}

//creating internet gatway and attaching to public vpc

resource "aws_internet_gateway" "my_internet_gateway" {

  vpc_id = aws_vpc.my_public_vpc.id

  tags = var.resource_tags

}

//create internet access

resource "aws_route" "my_vpc_internet_access" {

  route_table_id         = aws_route_table.my_vpc_route_table.id
  gateway_id             = aws_internet_gateway.my_internet_gateway.id
  destination_cidr_block = var.internet_destination_cidr_block
}

//creating route table

resource "aws_route_table" "my_vpc_route_table" {

  vpc_id = aws_vpc.my_public_vpc.id

  tags = var.resource_tags
}

//associate subnet with route table

resource "aws_route_table_association" "my_vpc_association" {

  count          = length(aws_subnet.my_public_subnet)
  route_table_id = aws_route_table.my_vpc_route_table.id

  subnet_id = aws_subnet.my_public_subnet[count.index].id


}

// creating instance profile for webserver

resource "aws_iam_instance_profile" "ec2_webserver_instance_profile" {

  name = "ec2_instance_profile"
  role = var.webserver_instance_role_name
  
}

//starting an ec2 instance in public subnet

resource "aws_instance" "webserver01" {

  ami                    = var.image
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.my_public_sg.id]
  subnet_id              = aws_subnet.my_public_subnet[1].id
  key_name               = var.keypair_name
  count                  = 1
  iam_instance_profile = aws_iam_instance_profile.ec2_webserver_instance_profile.name
  tags = var.resource_tags
}



