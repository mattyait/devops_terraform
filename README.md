[![Build Status](https://travis-ci.org/mattyait/devops_terraform.svg?branch=master)](https://travis-ci.org/mattyait/devops_terraform)
# devops_terraform

Build the docker image

    docker build -t terraform/terraform:latest -f Dockerfile .

Run the docker container

    docker run -i -d -v ~/environment/devops_terraform/:/mnt/workspace terraform/terraform:latest

Enter the Container and use it as a Dev Environment

    docker exec -it <container_id> bash

Setup the AWS Credentials

    aws configure
    AWS Access Key ID [None]: *********
    AWS Secret Access Key [None]: **********
    Default region name [None]:
    Default output format [Noµne]:

After Setup the Credentials, Initialize the terraform and execute the plan

        terraform fmt
        terraform init
        terraform plan
        
To Create the Infrastructure apply the terraform changes

        terraform apply

## Modules
- **vpc** : This is a module to create VPC, Private and all public subnets
- **asg** : This module is to create launch configuration and auto scaling group for Ec2

## Multiple Environment
Create the multiple workspace in case of handling the multiple env.

    terraform workspace new dev

To list and Select the specification workspace

    terraform workspace list
    terraform workspace select dev

Cd into the specific environment and run the terraform

    cd devops_terraform/env/dev
    terraform init
    terraform plan -var-file=./env.tfvar
    terraform apply -var-file=./env.tfvar
    
# To destory the created infratstructure

    terraform destroy -var-file=./env.tfvar

