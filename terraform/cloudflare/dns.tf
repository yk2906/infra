resource "cloudflare_record" "example_record" {
  name            = "mamelly.com"
  proxied         = false
  ttl             = 1
  type            = "A"
  content         = "217.142.224.159"
  zone_id         = "f8d0ddf4c963e35e758c7d49b81f6fb4"
}