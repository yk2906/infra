# report-bot(k8s上のGoサーバー)をインターネットに公開するためのCloudflare Tunnel。
# cloudflaredはk8sクラスタ内にDeploymentとして立て、report-bot Serviceへ外向き接続のみで中継する。
locals {
  cloudflare_account_id = "76ef25bb5eaf05b8a2d2825dd616051c"
}

resource "random_id" "report_bot_tunnel_secret" {
  byte_length = 32
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "report_bot" {
  account_id = local.cloudflare_account_id
  name       = "report-bot"
  secret     = random_id.report_bot_tunnel_secret.b64_std
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "report_bot" {
  account_id = local.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.report_bot.id

  config {
    ingress_rule {
      hostname = "report-bot.mamelly.com"
      service  = "http://report-bot.report-bot.svc.cluster.local:80"
    }
    # 最後は必ずキャッチオール
    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_record" "report_bot_tunnel" {
  name    = "report-bot"
  type    = "CNAME"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.report_bot.id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
  zone_id = "f8d0ddf4c963e35e758c7d49b81f6fb4"
}

output "report_bot_tunnel_token" {
  value     = cloudflare_zero_trust_tunnel_cloudflared.report_bot.tunnel_token
  sensitive = true
}
