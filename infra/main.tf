# Получение данных о доступных зонах
data "yandex_compute_image" "ubuntu" {
  family = var.image_family
}

# Используем существующую облачную сеть (VPC)
data "yandex_vpc_network" "kittygram_network" {
  name = "kittygram-network"
}

# Используем существующую подсеть
data "yandex_vpc_subnet" "kittygram_subnet" {
  name = "kittygram-subnet"
}

# Используем существующую группу безопасности
data "yandex_vpc_security_group" "kittygram_sg" {
  name = "kittygram-security-group"
}

# Cloud-init конфигурация
locals {
  cloud_init_config = templatefile("${path.module}/cloud-init.yml", {
    ssh_public_key = var.ssh_key
  })
}

# Виртуальная машина
resource "yandex_compute_instance" "kittygram_vm" {
  name        = "kittygram-vm"
  description = "Virtual machine for Kittygram application"
  zone        = var.zone

  resources {
    cores         = var.cores
    memory        = 4  # 4GB как в существующей ВМ
    core_fraction = 100  # 100% как в существующей ВМ
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.disk_size
      type     = var.disk_type
    }
  }

  network_interface {
    subnet_id          = data.yandex_vpc_subnet.kittygram_subnet.id
    nat                = true
    security_group_ids = [data.yandex_vpc_security_group.kittygram_sg.id]
  }

  metadata = {
    user-data = local.cloud_init_config
  }

  scheduling_policy {
    preemptible = true  # Прерываемая ВМ для экономии
  }

  labels = {
    project = "kittygram"
    env     = "production"  # Как в существующей ВМ
  }
}
