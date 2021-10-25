# Creating a VPC Through Terraform

## Description.

This guide explores how AWS Virtual Private Clouds can be created using Terraform Tool. 

Infrastructure as Code (IaC) is a key part of a balanced cloud breakfast. And when it comes to IaC tools, Terraform is one of the top tools out there.
We use Terraform to build an AWS VPC along with private/public Subnet and Network Gateway's for the VPC. 
We will be making a VPC with 6 Subnets: 3 Private Subnets and 3 Public Subnets, 1 NAT Gateways, 1 Internet Gateway, and 2 Route Tables.
We will also be creating a bastion host server , a webserver and a database server.
- Architecture for Amazon VPC on AWS
![architecture_diagram](https://user-images.githubusercontent.com/91482551/138722220-8ad11ed6-4ba9-4396-ae9d-7bae17112904.png)
- Bastion Host
![Bastion Host](https://user-images.githubusercontent.com/91482551/138719481-6decabb6-a659-4eca-9554-cb2db613c8a6.jpg)

### Prerequisites for this project
- Need a IAM user access with attached policies for the creation of VPC.
- Knowledge to the working principles of each AWS services especially VPC, EC2 and IP Subnetting.

## Terraform Installation 
You can download the latest version of terraform from the below mentioned link.

(https://www.terraform.io/downloads.html) .

### Prerequisites 
- Create an IAM user on your AWS console that have access to create the required resources.
- Create a dedicated directory where you can create terraform configuration files.

## Let’s Start!
> Terraform installation steps
```sh
wget https://releases.hashicorp.com/terraform/1.0.9/terraform_1.0.9_linux_amd64.zip
unzip terraform_1.0.9_linux_amd64.zip 
ls -l
-rwxr-xr-x 1 root root 79991413 May  6 18:03 terraform 
-rw-r--r-- 1 root root 32743141 May  6 18:50 terraform_1.0.9_linux_amd64.zip
mv terraform /usr/bin/
which terraform 
/usr/bin/terraform
```
### 1. Create your working folder.
I have chosen aws_projects
### 2.Create a variables.tf file
```sh
variable "region" {}
variable "access_key" {}
variable "secret_key" {}
variable "vpc_cidr" {}
variable "project" {}
variable "vpc_subnets" {}  
```
### 3.Create a provider.tf file 
```sh
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
```
### 4.Create a variables.tfvars
Terraform will automatically load variables from those files.
If any automatically loaded variables have the same names as variables specified in the Terraform Cloud workspace, the workspace's values will override the automatic values.

```sh
region      = "enter-your-region-here"
access_key  = "enter-your-access-key-here"
secret_key  = "enter-your-secret-key-here"
project     = "enter-name-of-your-project"
vpc_cidr    = "X.X.X.X/X"
vpc_subnets = "enter required number"
```
### 5.We are ready to init!
```sh
terraform init
```
### 6.Create a main.tf 

```sh
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project}-vpc"
  }
}
```
> To Gather All Available Subent Name
```sh
data "aws_availability_zones" "available" {
  state = "available"
}
```

> To create InterGateWay For VPC
```sh
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.project}-igw"
  }
}
```

> Creating public Subnet 01
```sh
resource "aws_subnet" "public1" {
    
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = cidrsubnet(var.vpc_cidr, var.vpc_subnets, 0)
  availability_zone        = element(data.aws_availability_zones.available.names,0)
  map_public_ip_on_launch  = true
  tags = {
    Name = "${var.project}-public1"
  }
}
```
> Creating public Subnet 02
```sh
resource "aws_subnet" "public2" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = cidrsubnet(var.vpc_cidr, var.vpc_subnets, 1)
  availability_zone        = element(data.aws_availability_zones.available.names,1)
  map_public_ip_on_launch  = true
  tags = {
    Name = "${var.project}-public2"
  }
}
```
> Creating public Subnet 03
```sh
resource "aws_subnet" "public3" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = cidrsubnet(var.vpc_cidr, var.vpc_subnets, 2)
  availability_zone        = element(data.aws_availability_zones.available.names,2)
  map_public_ip_on_launch  = true
  tags = {
    Name = "${var.project}-public-3"
  }
}
```
> Creating private Subnet 01
```sh
resource "aws_subnet" "private1" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = cidrsubnet(var.vpc_cidr, var.vpc_subnets, 3)
  availability_zone        = element(data.aws_availability_zones.available.names,3)
  map_public_ip_on_launch  = true
  tags = {
    Name = "${var.project}-private1"
  }
}
```
> Creating private Subnet 02
```sh
resource "aws_subnet" "private2" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = cidrsubnet(var.vpc_cidr, var.vpc_subnets, 4)
  availability_zone        = element(data.aws_availability_zones.available.names,4)
  map_public_ip_on_launch  = true
  tags = {
    Name = "${var.project}-private2"
  }
}
```
> Creating private Subnet 03
```sh
resource "aws_subnet" "private3" {
  vpc_id                   = aws_vpc.vpc.id
  cidr_block               = cidrsubnet(var.vpc_cidr, var.vpc_subnets, 5)
  availability_zone        = element(data.aws_availability_zones.available.names,5)
  map_public_ip_on_launch  = true
  tags = {
    Name = "${var.project}-private3"
  }
}
```
> Creating  Elastic IP For Nat Gateway
```sh
resource "aws_eip" "eip" {
  vpc      = true
  tags     = {
    Name = "${var.project}-eip"
  }
}
```
> Attaching Elastic IP to NAT gateway
```sh
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id
  tags = {
    Name = "${var.project}-nat"
  }
}
```
>  Creating Public Route Table
```sh
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
```
>  Creating Private Route Table
```sh
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
```
> Creating Public Route Table Association
```sh
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
```
> Creating Private Route Table Association
```sh
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
````
> Create an output.tf for getting  terrafrom output.
```sh
output "aws_eip" {
value = aws_eip.eip.public_ip
}
output "aws_vpc" {
value = aws_vpc.vpc.id
}
output "aws_internet_gateway" {
value = aws_internet_gateway.igw.id
}
output "aws_nat_gateway" {
value = aws_nat_gateway.nat.id
}
output "aws_route_table_public" {
value = aws_route_table.public.id
}
output "aws_route_table_private" {
value = aws_route_table.private.id
}
```
> Create a Security Group bastion
```sh
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
```
> Create a Security Group webserver
```sh
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
```
> Create a Security Group database
```sh
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

```
>  Create a Keypair
```sh
  resource "aws_key_pair" "key" {
  key_name   = "${var.project}-key"
  public_key = file("/root/aws-projects-key.pub")
  tags = {
    Name = "${var.project}-key"
  }
}
```
>  Create a bastion instance
```sh
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
```
>  Create a webserver instance
```sh
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
```
>  Create a database instance
```sh
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
```
#### Lets validate 
```sh
terraform validate
```
#### Lets plan the architecture and verify.
```sh
terraform plan
```
#### Lets apply 
```sh
terraform apply -var-file="variables.tfvars"
```

----
## Conclusion
That's how we use Terraform to build an AWS VPC.

That’s all. All you need is follow all these steps and clone this repository.
