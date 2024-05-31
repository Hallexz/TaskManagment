variable "yandex_cloud_token" {
  description = "Yandex Cloud API token"
  type        = string
  sensitive   = true
}

variable "yandex_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "yandex_folder_id" {
  description = "Yandex Folder ID"
  type        = string
}

variable "network_name" {
  description = "Network name"
  type        = string
  default     = "my-network"
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
  default     = "my-subnet"
}

variable "zone" {
  description = "Availability zone"
  type        = string
  default     = "ru-central1-b"
}

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.83.0" # Используйте последнюю доступную версию
    }
  }
}

provider "yandex" {
  token     = var.yandex_cloud_token
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
  zone      = var.zone
}

resource "yandex_vpc_network" "default" {
  name = var.network_name
  description = "Пример сети"
  labels = {
    "key" = "value"
  }
}

resource "yandex_vpc_subnet" "default" {
  name           = var.subnet_name
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["10.128.0.0/20"]
  zone           = var.zone
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance" "default" {
  name        = "my-instance"
  platform_id = "standard-v1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type     = "network-hdd"
      size     = 10
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat       = true
  }

  metadata = {
    foo = "bar"
  }
}