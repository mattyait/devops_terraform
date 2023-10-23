#==========Global Variables=====
aws_region = "ap-southeast-2"

#==========Module toggle on/off variable (default is on for all within deployment) =============
ecs_cluster_create   = false
ecs_service_create   = false
codebuild_create     = false
aws_secret_create    = false
aws_appstream_create = false
db_create            = false

eks_cluster_create = true

#==========VPC Variables==========
environment                  = "devops"
vpc_name                     = "terraform"
vpc_cidr_block               = "10.24.0.0/19"
private_subnet_1a_cidr_block = "10.24.0.0/21"
private_subnet_1b_cidr_block = "10.24.8.0/21"

public_subnet_1a_cidr_block = "10.24.16.0/21"
public_subnet_1b_cidr_block = "10.24.24.0/21"
key_name                    = "devops_terraform"

#==========ECS Variable==========
ecs_cluster_name            = "test-ecs-cluster-app"
ecs_security_group_name     = "test-ecs-cluster-app-sg"
ecs_alb_security_group_name = "test-alb-app-sg"
ecs_ec2_ami                 = "ami-01711df8fe87a6217"
ecs_ec2_instance_type       = "t3.medium"
ec2_root_volume_size        = "50"
ec2_ebs_volume_size         = "50"
ecs_name                    = "test-api-spec"
ecs_alb_target_group_name   = "test-api-spec-tg"
target_container_name       = "test-app"
container_image             = "golang:1.12.5-alpine"
container_port              = "8080"
host_port                   = "0"

#============EKS Variables========
eks_cluster_version = "1.27"
eks_cluster_name    = "devops"

#============RDS Variables========
rds_name             = "dbname"
db_engine            = "mysql"
db_engine_version    = "5.7.19"
db_instance_type     = "db.t2.medium"
db_allocated_storage = "5"
db_username          = "user"
db_password          = "keepyourpasswordsecure"

#=============Codebuild variables========
codebuild_env_image        = "image_name"
codebuild_service_role_arn = "service_role"
buildspec_path             = "buildspec.yml"

#=============AWS Secret Mgr variables========
secret_values = {
  Value1 = "abcdefgh"
  Value2 = "123456789"
}
