# Don't Starve Together on Terraform AKS

Deploy a Dont' Starve Together server with the Terraform AKS module.

## Get Started

```bash
terraform init
terraform apply
```

Then you need to open up ports 10999, 11000, 12346, 12347 UDP on the network security group in the node resource group. Terraform can't do that as of now.

## Data Storage
The server data is in the storage account in the node resource group. You can SFTP into it if needed.

## Why?
This is mostly a test for Azure Bob Storage NFS v3 on AKS. No real practicality here. 