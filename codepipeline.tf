resource "aws_codepipeline" "project" {
  name     = "${var.app}-pipeline"
  role_arn = "${aws_iam_role.codebuild_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.releases.id}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["${var.app}"]

      configuration {
        Owner                = "${var.github_org}"
        Repo                 = "${var.project}"
        PollForSourceChanges = "true"
        Branch               = "master"
        OAuthToken           = "${var.github_token}"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["${var.app}"]
      version          = "1"

      configuration {
        ProjectName = "${aws_codebuild_project.project.name}"
      }
    }
  }

  stage {
    name = "DeployDev"

    action {
      name            = "Deploy"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["${var.app}"]
      version         = "1"

      configuration {
        ProjectName = "${aws_codebuild_project.deploy_dev.name}"
      }
    }
  }

  stage {
    name = "DeployProd"

    action {
      name      = "ApprovalStage"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      run_order = 1
      version   = "1"
    }

    action {
      name            = "Deploy"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["${var.app}"]
      run_order       = 2
      version         = "1"

      configuration {
        ProjectName = "${aws_codebuild_project.deploy_prod.name}"
      }
    }
  }
}
