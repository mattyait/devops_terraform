module "db_security_group" {
  enable              = "${var.db_create}"
  source              = "../modules/aws/network/security_group"
  security_group_name = "rds-sg"
  vpc_id              = "${module.vpc.vpc_id_out}"
  environment         = "${var.environment}"
  description         = "rds-sg"

  ingress_with_source_security_group_id = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      description              = "MYSQL port"
      source_security_group_id = "${module.eks_cluster.worker_security_group_id}"
    },
  ]

  egress_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow outgoing traffic"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]
}

module "db" {
  enable     = "${var.db_create}"
  source     = "../modules/aws/database/db_main"
  identifier = "${var.environment}-${var.rds_name}"

  engine            = "${var.db_engine}"
  engine_version    = "${var.db_engine_version}"
  instance_class    = "${var.db_instance_type}"
  allocated_storage = "${var.db_allocated_storage}"

  name     = "${var.rds_name}"
  username = "${var.db_username}"
  password = "${var.db_password}"
  port     = "3306"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = ["${module.db_security_group.security_group_id_out}"]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  tags = {
    Name        = "${var.environment}-${var.rds_name}"
    Environment = "${var.environment}"
    Created_By  = "${var.created_by}"
  }

  # DB subnet group
  subnet_ids = ["${module.private_subnet_1a.subnet_id_out}", "${module.private_subnet_1b.subnet_id_out}"]

  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "${var.environment}-${var.rds_name}"

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8"
    },
    {
      name  = "character_set_server"
      value = "utf8"
    },
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}
