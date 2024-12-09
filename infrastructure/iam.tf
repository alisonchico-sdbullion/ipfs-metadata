# Data sources for IAM Policy Documents
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "ecs_task_policy" {
  name        = "${local.name}-ecs-ssm-task-policy"
  description = "Policy to allow ECS Task via Session Manager"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel",
        "ssm:UpdateInstanceInformation",
        "ecs:ExecuteCommand",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "ecsTaskRole" {
  name               = "${local.name}-task-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "attach_ecs_ssm_task_policy" {
  role       = aws_iam_role.ecsTaskRole.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}



