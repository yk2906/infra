resource "cloudflare_record" "example_record" {
  name    = "mamelly.com"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "217.142.224.159"
  zone_id = local.mamelly_zone_id
}

resource "cloudflare_record" "argocd" {
  name    = "argocd"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "100.86.157.73"
  zone_id = local.mamelly_zone_id
}

resource "cloudflare_record" "argo_workflows" {
  name    = "workflows"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "100.86.157.73"
  zone_id = local.mamelly_zone_id
}
