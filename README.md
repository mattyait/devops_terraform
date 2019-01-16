[![Build Status](https://travis-ci.org/mattyait/devops_terraform.svg?branch=master)](https://travis-ci.org/mattyait/devops_terraform)
# devops_terraform

Build the docker image

    docker build -t terraform/terraform:latest -f Dockerfile .

Run the docker container

    docker run -i -d -v ~/environment/devops_terraform/:/mnt/workspace terraform/terraform:latest

Enter the Container and use it as a Dev Environment

    docker exec -it a8 bash 
    
Setup the AWS Credentials

    aws configure
    AWS Access Key ID [None]: *********
    AWS Secret Access Key [None]: **********
    Default region name [None]:
    Default output format [Noµne]:

After Setup the Credentials, Initialize the terraform and execute the plan

    terraform init VPC
    terraform plan VPC
