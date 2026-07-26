resource "google_service_account" "test_service_account" {
  account_id   = "test-service-account"
  display_name = "test-service-account"
  project      = "work-425105"
}
