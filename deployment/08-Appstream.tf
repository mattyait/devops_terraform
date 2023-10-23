resource "aws_cloudformation_stack" "appstream_sample" {
  count = var.aws_appstream_create ? 1 : 0
  name  = "appstream-sample"

  parameters = {
    AppStreamFleetName = "demo_fleet_terraform"
    AppStreamStackName = "demo_stack_terraform"
    FleetImageName     = "Sample_Image_6Apr"
    FleetInstanceType  = "stream.standard.medium"
  }
  template_body = data.template_file.appstream_cloudformation_template[0].rendered

  tags = {
    Environment = "${var.environment}"
    Created_By  = "${var.created_by}"
  }
}


data "template_file" "appstream_cloudformation_template" {
  count    = var.aws_appstream_create ? 1 : 0
  template = file("${path.module}/../cloudFormation/appstream.yaml")
  vars = {
    private_subnet_1a  = "${module.private_subnet_1a.subnet_id_out}"
    private_subnet_1b  = "${module.private_subnet_1b.subnet_id_out}"
    security_group     = "sg-02a85b9d8dcddb6d5"
    appstream_role_arn = "arn:aws:iam::948174138596:role/service-role/AmazonAppStreamServiceAccess"
    storage_s3_arn     = "arn:aws:s3:::appstream-storage-persistence"

  }
}
