variable "aws_region" {
  description = "IAM Identity Centerのインスタンスが属するリージョン。"
  type        = string
  default     = "ap-northeast-1"
}

variable "sso_user_email" {
  description = "IAM Identity Centerに作成するユーザーのメールアドレス（ユーザー名としても使用）。"
  type        = string
  default     = "yk0956tfdev@gmail.com"
}

variable "sso_user_given_name" {
  description = "IAM Identity Centerユーザーの名（表示用属性）。"
  type        = string
  default     = "Yuto"
}

variable "sso_user_family_name" {
  description = "IAM Identity Centerユーザーの姓（表示用属性）。"
  type        = string
  default     = "Kohama"
}

variable "permission_set_name" {
  description = "作成するパーミッションセット名。"
  type        = string
  default     = "AdministratorAccess"
}
