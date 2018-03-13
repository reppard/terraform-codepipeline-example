resource "aws_codebuild_project" "project" {
  name          = "${var.project}"
  description   = "${var.project} CodeBuild Project"
  build_timeout = "10"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "${var.docker_build_image}"
    type         = "LINUX_CONTAINER"
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  artifacts {
    type = "CODEPIPELINE"
  }
}

resource "aws_codebuild_project" "deploy_dev" {
  name          = "${var.project}-deploy-dev"
  description   = "${var.project} CodeBuild Project Deploy Dev"
  build_timeout = "12"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "hashicorp/terraform:0.11.1"
    type         = "LINUX_CONTAINER"

    environment_variable {
      "name"  = "ENVIRONMENT"
      "value" = "dev"
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "tf/infra/buildspec.yml"
  }

  artifacts {
    type = "CODEPIPELINE"
  }
}

resource "aws_codebuild_project" "deploy_prod" {
  name          = "${var.project}-deploy-prod"
  description   = "${var.project} CodeBuild Project Deploy Prod"
  build_timeout = "12"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "hashicorp/terraform:0.11.1"
    type         = "LINUX_CONTAINER"

    environment_variable {
      "name"  = "ENVIRONMENT"
      "value" = "prod"
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "tf/infra/buildspec.yml"
  }

  artifacts {
    type = "CODEPIPELINE"
  }
}
