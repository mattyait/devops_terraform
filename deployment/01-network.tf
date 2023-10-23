#======= Creating VPC=========
module "vpc" {
  source         = "../modules/aws/network/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  name           = var.vpc_name

  tags = {
    Name                                                               = "${var.environment}-${var.vpc_name}"
    Environment                                                        = "${var.environment}"
    "kubernetes.io/cluster/${var.environment}-${var.eks_cluster_name}" = "shared"
    Created_By                                                         = "${var.created_by}"
  }

}

#=======Creating internet Gateway and attach it to public route table ==========
module "internet_gateway" {
  source = "../modules/aws/network/internet_gateway"
  vpc_id = module.vpc.vpc_id_out

  tags = {
    Name        = "${var.environment}_int_gateway"
    Environment = "${var.environment}"
    Created_By  = "${var.created_by}"
  }
}

module "public_route" {
  source     = "../modules/aws/network/route_table"
  vpc_id     = module.vpc.vpc_id_out
  cidr_block = "0.0.0.0/0"
  gateway_id = module.internet_gateway.internet_gateway_id_out

  tags = {
    Name        = "${var.environment}_public"
    Environment = "${var.environment}"
    Created_By  = "${var.created_by}"
  }

}

#======= Creating Public Subnet in both 1a and 1b Availability_zone========================
module "public_subnet_1a" {
  source            = "../modules/aws/network/subnet"
  vpc_id            = module.vpc.vpc_id_out
  cidr_block        = var.public_subnet_1a_cidr_block
  availability_zone = "ap-southeast-2a"

  tags = {
    Name                                                               = "${var.environment}_public_1a"
    Environment                                                        = "${var.environment}"
    "kubernetes.io/cluster/${var.environment}-${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                                           = 1
    Created_By                                                         = "${var.created_by}"
  }
}

module "public_subnet_1b" {
  source            = "../modules/aws/network/subnet"
  vpc_id            = module.vpc.vpc_id_out
  cidr_block        = var.public_subnet_1b_cidr_block
  availability_zone = "ap-southeast-2b"

  tags = {
    Name                                                               = "${var.environment}_public_1b"
    Environment                                                        = "${var.environment}"
    "kubernetes.io/cluster/${var.environment}-${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                                           = 1
    Created_By                                                         = "${var.created_by}"
  }
}

# associate routing table with subnet
resource "aws_route_table_association" "public_subnet_route_association_1a" {
  subnet_id      = module.public_subnet_1a.subnet_id_out
  route_table_id = module.public_route.route_table_id_out
}

resource "aws_route_table_association" "public_subnet_route_association_1b" {
  subnet_id      = module.public_subnet_1b.subnet_id_out
  route_table_id = module.public_route.route_table_id_out
}

#======= Creating Private Subnet in 1a Availability zone========================
#======= Creating Nat Gateway and attaching to private route for 1a zone=========
module "nat_gateway_1a" {
  source    = "../modules/aws/network/nat_gateway"
  subnet_id = module.public_subnet_1a.subnet_id_out

  tags = {
    Name        = "${var.environment}_public_1a"
    Environment = "${var.environment}"
    Created_By  = "${var.created_by}"
  }
}

module "private_subnet_1a" {
  source            = "../modules/aws/network/subnet"
  vpc_id            = module.vpc.vpc_id_out
  cidr_block        = var.private_subnet_1a_cidr_block
  availability_zone = "ap-southeast-2a"

  tags = {
    Name                                                               = "${var.environment}_private_1a"
    Environment                                                        = "${var.environment}"
    "kubernetes.io/cluster/${var.environment}-${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                                  = 1
    Created_By                                                         = "${var.created_by}"
  }
}

module "private_route_1a" {
  source     = "../modules/aws/network/route_table"
  vpc_id     = module.vpc.vpc_id_out
  cidr_block = "0.0.0.0/0"
  gateway_id = module.nat_gateway_1a.nat_gateway_id

  tags = {
    Name        = "${var.environment}_private_1a"
    Environment = "${var.environment}"
    Created_By  = "${var.created_by}"
  }
}

# associate routing table with subnet
resource "aws_route_table_association" "private_subnet_route_association_1a" {
  subnet_id      = module.private_subnet_1a.subnet_id_out
  route_table_id = module.private_route_1a.route_table_id_out
}

#======= Creating Private Subnet in 1b Availability zone========================
#======= Creating Nat Gateway and attaching to priavte route for 1b zone=========
module "nat_gateway_1b" {
  source    = "../modules/aws/network/nat_gateway"
  subnet_id = module.public_subnet_1b.subnet_id_out

  tags = {
    Name        = "${var.environment}_public_1b"
    Environment = "${var.environment}"
    Created_By  = "${var.created_by}"
  }
}

module "private_subnet_1b" {
  source            = "../modules/aws/network/subnet"
  vpc_id            = module.vpc.vpc_id_out
  cidr_block        = var.private_subnet_1b_cidr_block
  availability_zone = "ap-southeast-2b"

  tags = {
    Name                                                               = "${var.environment}_private_1b"
    Environment                                                        = "${var.environment}"
    "kubernetes.io/cluster/${var.environment}-${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                                  = 1
    Created_By                                                         = "${var.created_by}"
  }
}

module "private_route_1b" {
  source     = "../modules/aws/network/route_table"
  vpc_id     = module.vpc.vpc_id_out
  cidr_block = "0.0.0.0/0"
  gateway_id = module.nat_gateway_1b.nat_gateway_id

  tags = {
    Name        = "${var.environment}_private_1b"
    Environment = "${var.environment}"
    Created_By  = "${var.created_by}"
  }
}

# associate routing table with subnet
resource "aws_route_table_association" "private_subnet_route_association_1b" {
  subnet_id      = module.private_subnet_1b.subnet_id_out
  route_table_id = module.private_route_1b.route_table_id_out
}
