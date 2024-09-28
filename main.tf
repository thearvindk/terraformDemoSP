terraform {
  required_providers {
    aws = {  # AWS provider
        source = "hashicorp/aws"  # Provider source
        version = "5.69.0"  # Version specified
    }
  }
}

provider "aws" {
    region = "ap-south-1"  # AWS region
}
