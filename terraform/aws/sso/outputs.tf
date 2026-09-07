output "instance_arn" {
  value = local.instance_arn
}

output "identity_store_id" {
  value = local.identity_store_id
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "permission_set_arn" {
  value = aws_ssoadmin_permission_set.admin.arn
}

output "sso_user_id" {
  value = aws_identitystore_user.admin.user_id
}
