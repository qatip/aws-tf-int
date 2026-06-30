vpcs = {
  vpc1 = {
    name          = "vpc-01"
    cidr_block    = "10.1.0.0/16"
    location      = "East US"
  }

  vpc2 = {
    name          = "vpc-02"
    cidr_block = "10.2.0.0/16"
    location      = "West Europe"
  }
}

subnets = {
  vpc1 = {
    apps = "10.1.1.0/24"
    data = "10.1.2.0/24"
  }

  vpc2 = {
    apps = "10.2.1.0/24"
    data = "10.2.2.0/24"
  }
}