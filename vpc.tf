# Create VPC/Subnet/Security Group/Network ACL
provider "aws" {
    version = "~> 2.70"
    region     = var.region
}

# create the VPC
resource "aws_vpc" "CresolPOC_VPC" {
    cidr_block           = var.vpcCIDRblock
    instance_tenancy     = var.instanceTenancy 
    enable_dns_support   = var.dnsSupport 
    enable_dns_hostnames = var.dnsHostNames
    tags = {
        Name = "CresolPOC_VPC"
    }
}

# create the Subnet
resource "aws_subnet" "CresolPOC_VPC_Subnet" {
    vpc_id                  = aws_vpc.CresolPOC_VPC.id
    cidr_block              = var.subnetCIDRblock
    map_public_ip_on_launch = var.mapPublicIP 
    availability_zone       = var.availabilityZone
    tags = {
        Name = "CresolPOC_VPC_Subnet"
    }
}

# Create the Security Group
resource "aws_security_group" "CresolPOC_VPC_SecurityGroup" {
    vpc_id       = aws_vpc.CresolPOC_VPC.id
    name         = "CresolPOC_VPC_Security_Group"
    description  = "CresolPOC_VPC_Security_Group"
    
    # allow ingress of port 22
    ingress {
        cidr_blocks = var.ingressCIDRblock  
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
    } 
  
    # allow egress of all ports
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "CresolPOC_VPC_SecurityGroup"
        Description = "CresolPOC_VPC_SecurityGroup"
    }
}

# create VPC Network access control list
resource "aws_network_acl" "CresolPOC_VPC_SecurityACL" {
    vpc_id = aws_vpc.CresolPOC_VPC.id
    subnet_ids = [ aws_subnet.CresolPOC_VPC_Subnet.id ]

    # allow ingress port 22
    ingress {
        protocol   = "tcp"
        rule_no    = 100
        action     = "allow"
        cidr_block = var.destinationCIDRblock 
        from_port  = 22
        to_port    = 22
    }
  
    # allow ingress port 80 
    ingress {
        protocol   = "tcp"
        rule_no    = 200
        action     = "allow"
        cidr_block = var.destinationCIDRblock 
        from_port  = 80
        to_port    = 80
    }
  
    # allow ingress ephemeral ports 
    ingress {
        protocol   = "tcp"
        rule_no    = 300
        action     = "allow"
        cidr_block = var.destinationCIDRblock
        from_port  = 1024
        to_port    = 65535
    }
  
    # allow egress port 22 
    egress {
        protocol   = "tcp"
        rule_no    = 100
        action     = "allow"
        cidr_block = var.destinationCIDRblock
        from_port  = 22 
        to_port    = 22
    }
  
    # allow egress port 80 
    egress {
        protocol   = "tcp"
        rule_no    = 200
        action     = "allow"
        cidr_block = var.destinationCIDRblock
        from_port  = 80  
        to_port    = 80 
    }
 
    # allow egress ephemeral ports
    egress {
        protocol   = "tcp"
        rule_no    = 300
        action     = "allow"
        cidr_block = var.destinationCIDRblock
        from_port  = 1024
        to_port    = 65535
    }

    tags = {
        Name = "CresolPOC_VPC_SecurityACL"
    }
}

# Create the Route Table
resource "aws_route_table" "CresolPOC_VPC_RouteTable" {
    vpc_id = aws_vpc.CresolPOC_VPC.id
    tags = {
            Name = "CresolPOC_VPC_RouteTable"
    }
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "CresolPOC_VPC_Association" {
  subnet_id      = aws_subnet.CresolPOC_VPC_Subnet.id
  route_table_id = aws_route_table.CresolPOC_VPC_RouteTable.id
} 