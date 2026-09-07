# 月次レポート完成チェック(check_monthly_reports.py)用のサービスアカウント。
# 対象スプレッドシートへの共有(閲覧者)は手動で行う。
# 鍵ファイル(秘密鍵)はTerraform管理外。gcloudで発行し ~/.config/bold-report-checker/service-account.json に手動配置。
resource "google_service_account" "report_checker" {
  account_id   = "report-checker"
  display_name = "Monthly Report Checker"
  project      = "bold-report-check-2026"
}

resource "google_project_service" "sheets" {
  project = "bold-report-check-2026"
  service = "sheets.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "drive" {
  project = "bold-report-check-2026"
  service = "drive.googleapis.com"

  disable_on_destroy = false
}
