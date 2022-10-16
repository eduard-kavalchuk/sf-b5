terraform {
  required_version = "~> 1.3.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.80.0"
    }
  }
}

resource "yandex_compute_image" "vm_image" {
  source_image = var.vm_image
}

resource "yandex_compute_instance" "vm" {
  # Required parameters
  zone = var.zone

  resources {
    cores         = var.cores
    memory        = var.memory_gb
    core_fraction = var.core_fraction
  }

  boot_disk {
    initialize_params {
      type     = "network-hdd"
      size     = var.disk_size_gb
      image_id = yandex_compute_image.vm_image.source_image
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  # Optional parameters
  service_account_id = var.service_account_id

  # Provide user data
  metadata = {
    serial-port-enable = "1"
    user-data          = file("${path.module}/userconfig.txt")
  }
}

output "internal_ip_address_vm" {
  value = yandex_compute_instance.vm.network_interface[0].ip_address
}

output "external_ip_address_vm" {
  value = yandex_compute_instance.vm.network_interface[0].nat_ip_address
}
