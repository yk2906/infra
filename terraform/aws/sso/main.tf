# IAM Identity Centerインスタンス自体はTerraformでは作成できない（スタンドアロンアカウント向けの
# `aws sso-admin create-instance` をCLIで一度だけ実行し、その後このコードでパーミッションセット・
# ユーザー・アカウント割り当てを管理する）。

data "aws_ssoadmin_instances" "this" {}

data "aws_caller_identity" "current" {}

locals {
  instance_arn      = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}

resource "aws_identitystore_user" "admin" {
  identity_store_id = local.identity_store_id
  user_name         = var.sso_user_email

  display_name = "${var.sso_user_given_name} ${var.sso_user_family_name}"

  name {
    given_name  = var.sso_user_given_name
    family_name = var.sso_user_family_name
  }

  emails {
    value   = var.sso_user_email
    primary = true
  }
}

resource "aws_ssoadmin_permission_set" "admin" {
  name             = var.permission_set_name
  instance_arn     = local.instance_arn
  session_duration = "PT12H"
}

resource "aws_ssoadmin_managed_policy_attachment" "admin" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_ssoadmin_account_assignment" "admin" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn

  principal_id   = aws_identitystore_user.admin.user_id
  principal_type = "USER"

  target_id   = data.aws_caller_identity.current.account_id
  target_type = "AWS_ACCOUNT"

  depends_on = [aws_ssoadmin_managed_policy_attachment.admin]
}
