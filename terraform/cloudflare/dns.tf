resource "cloudflare_record" "example_record" {
  name    = "mamelly.com"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "217.142.224.159"
  zone_id = "f8d0ddf4c963e35e758c7d49b81f6fb4"
}

resource "cloudflare_record" "argocd" {
  name    = "argocd"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "100.86.157.73"
  zone_id = "f8d0ddf4c963e35e758c7d49b81f6fb4"
}

resource "cloudflare_record" "argo_workflows" {
  name    = "workflows"
  proxied = false
  ttl     = 1
  type    = "A"
  content = "100.86.157.73"
  zone_id = "f8d0ddf4c963e35e758c7d49b81f6fb4"
}