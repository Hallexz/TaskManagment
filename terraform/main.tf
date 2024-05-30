variable "yandex_cloud_token" {
  description = "Yandex Cloud API token"
  type = string
  sensitive = true
}

variable "network_name" {
  description = "Network name"
  type = string
  default = "my-network"
}


variable "subnet_name" {
  description = "Subnet name"
  type = string
  default = "my-subnet"
}


variable "zone" {
  description = "Availability zone"
  type = string
  default = "ru-central1-b"
}


provider "yandex" {
  token = var.yandex_cloud_token
}


resource "yandex_network" "default" {
  name = var.network_name
  description = "Пример сети"
  labels = {
    "key" = "value"
  }
}


resource "yandex_network_subnet" "default" {
  name = var.subnet_name
  network_id = yandex_network.default.id
  zone = var.zone
  ip_version = "ipv4"
  address_space {
    cidr_blocks = ["10.128.0.0/20"]
  }
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance" "default" {
  name = "my-instance"
  zone = var.zone
  platform_id = "standard-v1"
  resources {
    cores  = 2
    memory = 2
  }
  network_interface {
    network_id = yandex_network.default.id
    subnet_id = yandex_network_subnet.default.id
    nat_ip {
    }
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type     = "network-hdd"
      size     = 10
    }
  }