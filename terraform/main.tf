terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


provider "aws" {
  region = "us-east-1"
}

module "network" {
  source = "./modules/network"
}


module "ec2" {
  source = "./modules/ec2"
  vpc_id = module.network.vpc_id
  public_subnet_id = module.network.public_subnet_id
  private_subnet_id = module.network.private_subnet_id
  private_cidr_block = module.network.private_cidr_block
}

output "buscar_public_ip" {
  value = module.ec2.public_ip_buscar
  description = "IP publico do buscar"
}

output "pitstop_public_ip" {
  value = module.ec2.public_ip_pitstop
  description = "IP publico do pitstop"
}

output "motion_public_ip" {
  value = module.ec2.public_ip_motion
  description = "IP publico do motion"
}