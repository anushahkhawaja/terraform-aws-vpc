
variable "availability_zones" {
  type = list(string)
}

variable "max_subnets" {
  default     = "3"
  description = "Maximum number of subnets that can be created. The variable is used for CIDR blocks calculation"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.20.0.0/16"
}

variable "subnet_cidr_block" {
  type        = string
  default     = "10.20.0.0/24"
  description = "Base CIDR block which is divided into subnet CIDR blocks"
}

variable "image" {
  type    = string
  default = "ami-03d315ad33b9d49c4"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "keypair_name" {
  type    = string
  default = "aws_keypair_N.Virginia"
  sensitive = true
}

variable "internet_destination_cidr_block" {
  type    = string
  default = "0.0.0.0/0"

}

variable "ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
}

variable "egress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
}

variable "resource_tags" {
  type        = map(string)
  description = "Tags to set for all resources"
}

variable "webserver_instance_role_name" {
  type = string
  description = "Role name that will be passed to ec2 instance profile"
}