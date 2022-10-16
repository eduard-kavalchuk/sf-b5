terraform {
  required_version = "~> 1.3.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.80.0"
    }
  }
  # https://cloud.yandex.com/en/docs/tutorials/infrastructure-management/terraform-state-storage
  # IMPORTANT! Create a bucket first, then uncomment this block to create a backend
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "b-54-bucket"
    region     = "ru-central1-a"
    key        = "./terraform.tfstate"
    access_key = "<access_key>"
    secret_key = "<secret_key>"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  token              = var.token
  cloud_id           = var.cloud_id
  folder_id          = var.folder_id
  zone               = "ru-central1-a"
  storage_access_key = var.storage_access_key
  storage_secret_key = var.storage_secret_key
}

resource "yandex_vpc_network" "vpc_network" {}

resource "yandex_vpc_subnet" "lemp_subnet" {
  name           = "lemp subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.vpc_network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "lamp_subnet" {
  name           = "lamp subnet"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.vpc_network.id
  v4_cidr_blocks = ["192.168.11.0/24"]
}

module "lemp_server" {
  zone               = yandex_vpc_subnet.lemp_subnet.zone
  source             = "./instances"
  vm_image           = "fd8lur056bsfs83gfnvm"
  subnet_id          = yandex_vpc_subnet.lemp_subnet.id
  service_account_id = var.service_account_id
}

module "lamp_server" {
  zone               = yandex_vpc_subnet.lamp_subnet.zone
  source             = "./instances"
  vm_image           = "fd8pud26a17jdkbf9ecb"
  subnet_id          = yandex_vpc_subnet.lamp_subnet.id
  service_account_id = var.service_account_id
}

resource "yandex_lb_target_group" "lb_target_group" {
  folder_id = var.folder_id
  region_id = "ru-central1"
  target {
    subnet_id = yandex_vpc_subnet.lemp_subnet.id
    address   = module.lemp_server.internal_ip_address_vm
  }
  target {
    subnet_id = yandex_vpc_subnet.lamp_subnet.id
    address   = module.lamp_server.internal_ip_address_vm
  }
}

resource "yandex_lb_network_load_balancer" "lb" {
  name = "default-lb"
  listener {
    name = "default-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.lb_target_group.id

    healthcheck {
      name = "tcp-port-22"
      tcp_options {
        port = 22
      }
    }
  }
}

resource "yandex_iam_service_account" "sa" {
  name        = "sf-sa"
  description = "service account for object storage"
  folder_id   = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "sa-roles" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

resource "yandex_storage_bucket" "b-54-bucket" {
  bucket     = "b-54-bucket"
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
}
