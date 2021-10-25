###################################################################
# Gathering All Subent Name
###################################################################

data "aws_availability_zones" "az" {
  state = "available"
}

###################################################################
# VPC Creation
###################################################################
resource "aws_vpc" "vpc" {
    
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project}-vpc"
  }   
}

###################################################################
# Internet GateWay For VPC
###################################################################
resource "aws_internet_gateway" "igw" {
    
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project}-igw"
  }
}

###################################################################
# Public Subnet 01
###################################################################

resource "aws_subnet" "public1" {
    
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = cidrsubnet(var.vpc_cidr, var.vpc_subnets, 0)
  availability_zone        = element(data.aws_availability_zones.az.names,0)
  map_public_ip_on_launch  = true
  tags = {
    Name = "${var.project}-public1"
  }
}

###################################################################
# Public Subnet 02
###################################################################

resource "aws_subnet" "public2" {
    
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = cidrsubnet(var.vpc_cidr, var.vpc_subnets, 1)
  availability_zone        = element(data.aws_availability_zones.az.names,1)
  map_public_ip_on_launch  = true
  tags = {
    Name = "${var.project}-public2"
  }
}


###################################################################
# Public Subnet 03
###################################################################

resource "aws_subnet" "public3" {
    
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = cidrsubnet(var.vpc_cidr, var.vpc_subnets, 2)
  availability_zone        = element(data.aws_availability_zones.az.names,2)
  map_public_ip_on_launch  = true
  tags = {
    Name = "${var.project}-public-3"
  }
}

###################################################################
# Private Subnet 01
###################################################################

resource "aws_subnet" "private1" {
    
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = cidrsubnet(var.vpc_cidr, var.vpc_subnets, 3)
  availability_zone        = element(data.aws_availability_zones.az.names,0)
  map_public_ip_on_launch  = true
  tags = {
    Name = "${var.project}-private1"
  }
}

###################################################################
# Private Subnet 02
###################################################################

resource "aws_subnet" "private2" {
    
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = cidrsubnet(var.vpc_cidr, var.vpc_subnets, 4)
  availability_zone        = element(data.aws_availability_zones.az.names,1)
  map_public_ip_on_launch  = true
  tags = {
    Name = "${var.project}-private2"
  }
}


###################################################################
# Private Subnet 03
###################################################################

resource "aws_subnet" "private3" {
    
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = cidrsubnet(var.vpc_cidr, var.vpc_subnets, 5)
  availability_zone        = element(data.aws_availability_zones.az.names,2)
  map_public_ip_on_launch  = true
  tags = {
    Name = "${var.project}-private3"
  }
}

###################################################################
# Creating Elastic Ip For Nat Gateway.
###################################################################

resource "aws_eip" "eip" {
  vpc      = true
  tags     = {
    Name = "${var.project}-eip"
  }
}


###################################################################
# Creating Elastic Ip For Nat Gateway.
###################################################################

resource "aws_nat_gateway" "nat" {
    
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "${var.project}-nat"
  }
}

###################################################################
# Public Route Table
###################################################################

resource "aws_route_table" "public" {
    
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project}-public"
  }
}

###################################################################
# Private Route Table
###################################################################

resource "aws_route_table" "private" {
    
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.project}-private"
  }
}

###################################################################
# Public Route Table Association
###################################################################

resource "aws_route_table_association" "public1" {        
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {      
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "public3" {       
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.public.id
}

###################################################################
# Private Route Table Association
###################################################################

resource "aws_route_table_association" "private1" {        
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {      
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}


resource "aws_route_table_association" "private3" {       
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private.id
}
###################################################################
# SecurityGroup bastion
###################################################################


resource "aws_security_group" "bastion" {
    
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.project}-bastion"
  description = "allow 22 port"

  ingress = [
    {
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = [ "0.0.0.0/0" ]
      ipv6_cidr_blocks = [ "::/0" ]
    } 
      
  ]

  egress = [
    { 
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]

  tags = {
    Name = "${var.project}-bastion"
    Project = var.project
  }
}


###################################################################
# SecurityGroup webserver
###################################################################


resource "aws_security_group" "webserver" {
    
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.project}-webserver"
  description = "allow 80,443,22 port"

  ingress = [
    {
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = [ "0.0.0.0/0" ]
      ipv6_cidr_blocks = [ "::/0" ]
    },
    {
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = [ "0.0.0.0/0" ]
      ipv6_cidr_blocks = [ "::/0" ]
    },
    {
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      security_groups  = [ aws_security_group.bastion.id ]
    }
      
  ]

  egress = [
     { 
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]

  tags = {
    Name = "${var.project}-webserver"
    Project = var.project
  }
}


###################################################################
# SecurityGroup database
###################################################################


resource "aws_security_group" "database" {
    
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.project}-database"
  description = "allow 3306,22 port"

  ingress = [
    
    {
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      security_groups  = [ aws_security_group.bastion.id ]
    },
    {
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 3306
      to_port          = 3306
      protocol         = "tcp"
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      security_groups  = [ aws_security_group.webserver.id ]
    }
      
  ]

  egress = [
     { 
      description      = ""
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]

  tags = {
    Name = "${var.project}-database"
    Project = var.project
  }
}



###############################################################################
# Keypair Creation
###############################################################################


resource "aws_key_pair" "key" {
  key_name   = "${var.project}-key"
  public_key = file("/root/aws-projects-key.pub")
  tags = {
    Name = "${var.project}-key"
  }
}


###############################################################################
# bastion
###############################################################################

resource "aws_instance" "bastion" {

  ami                          =  "ami-041d6256ed0f2061c"
  instance_type                =  "t2.micro"
  subnet_id                    =  aws_subnet.public2.id
  vpc_security_group_ids       =  [ aws_security_group.bastion.id]
  key_name                     =  aws_key_pair.key.id
  tags = {
    Name = "${var.project}-bastion"
    Project = var.project
  }

}


###############################################################################
# webserver
###############################################################################

resource "aws_instance" "webserver" {

  ami                          =  "ami-041d6256ed0f2061c"
  instance_type                =  "t2.micro"
  subnet_id                    =  aws_subnet.public1.id
  vpc_security_group_ids       =  [ aws_security_group.webserver.id]
  key_name                     =  aws_key_pair.key.id
  tags = {
    Name = "${var.project}-webserver"
    Project = var.project
  }
  
}

###############################################################################
# database
###############################################################################

resource "aws_instance" "database" {

  ami                          =  "ami-041d6256ed0f2061c"
  instance_type                =  "t2.micro"
  subnet_id                    =  aws_subnet.private1.id
  vpc_security_group_ids       =  [ aws_security_group.database.id]
  key_name                     =  aws_key_pair.key.id
  tags = {
    Name = "${var.project}-database"
    Project = var.project
  }
  
}

#####################################-END-#######################################
