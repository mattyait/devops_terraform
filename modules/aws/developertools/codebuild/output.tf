output "codebuild_project_id_out" {
  value = "${aws_codebuild_project.codebuild[0].id}"
}

output "codebuild_project_arn_out" {
  value = "${aws_codebuild_project.codebuild[0].arn}"
}
