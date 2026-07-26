resource "google_compute_resource_policy" "dev_schedule" {
  name   = "dev-koha0101z-schedule"
  region = "us-central1"

  instance_schedule_policy {
    vm_start_schedule {
      schedule = "0 8 * * *"
    }
    vm_stop_schedule {
      schedule = "0 22 * * *"
    }
    time_zone = "Asia/Tokyo"
  }
}

resource "google_compute_instance" "dev-koha0101z" {
  name                       = "dev-koha0101z"
  machine_type               = "e2-micro"
  zone                       = "us-central1-a"
  key_revocation_action_type = "NONE"

  boot_disk {
    initialize_params {
      image = "https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2604-resolute-amd64-v20260723"
    }
  }

  network_interface {
    network = "default"

    access_config {
      # 外部IPを維持する(nat_ipは指定しなければ自動割当のまま扱われます)
    }
  }

  service_account {
    email = "875481976225-compute@developer.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  resource_policies = [google_compute_resource_policy.dev_schedule.self_link]
}
