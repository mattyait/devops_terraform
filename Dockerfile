FROM golang:alpine

ENV TERRAFORM_VERSION=0.10.0

RUN apk add --update git bash openssh

ENV TF_DEV=true
ENV TF_RELEASE=true
ENV PROJDIR=/mnt/workspace
WORKDIR $GOPATH/src/github.com/hashicorp/terraform
RUN git clone https://github.com/hashicorp/terraform.git ./ && \
git checkout v${TERRAFORM_VERSION} && \
/bin/bash scripts/build.sh

RUN apk add py-pip && \
    pip install --upgrade pip && \
    pip install awscli
    
WORKDIR $PROJDIR