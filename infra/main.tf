# Получение данных о доступных зонах
data "yandex_compute_image" "ubuntu" {
  family = var.vm_image_family
}

# Получение SSH ключа
data "local_file" "ssh_public_key" {
  filename = pathexpand(var.ssh_public_key_path)
}

# Облачная сеть (VPC)
resource "yandex_vpc_network" "kittygram_network" {
  name        = "kittygram-network"
  description = "Network for Kittygram application"
}

# Подсеть
resource "yandex_vpc_subnet" "kittygram_subnet" {
  name           = "kittygram-subnet"
  description    = "Subnet for Kittygram application"
  zone           = var.default_zone
  network_id     = yandex_vpc_network.kittygram_network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Группа безопасности
resource "yandex_vpc_security_group" "kittygram_sg" {
  name        = "kittygram-security-group"
  description = "Security group for Kittygram application"
  network_id  = yandex_vpc_network.kittygram_network.id

  # Исходящий трафик - разрешен весь
  egress {
    description    = "All outbound traffic"
    protocol       = "ANY"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH доступ
  ingress {
    description    = "SSH access"
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP доступ к приложению (порт gateway)
  ingress {
    description    = "HTTP access to gateway"
    protocol       = "TCP"
    port           = 9000
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS доступ (дополнительно)
  ingress {
    description    = "HTTPS access"
    protocol       = "TCP"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP доступ (дополнительно)
  ingress {
    description    = "HTTP access"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Cloud-init конфигурация
locals {
  cloud_init_config = templatefile("${path.module}/cloud-init.yml", {
    ssh_public_key = trimspace(data.local_file.ssh_public_key.content)
  })
}

# Виртуальная машина
resource "yandex_compute_instance" "kittygram_vm" {
  name        = "kittygram-vm"
  description = "Virtual machine for Kittygram application"
  zone        = var.default_zone

  resources {
    cores  = var.vm_cores
    memory = var.vm_memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.vm_disk_size
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.kittygram_subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.kittygram_sg.id]
  }

  metadata = {
    user-data = local.cloud_init_config
  }

  scheduling_policy {
    preemptible = true  # Прерываемая ВМ для экономии
  }

  labels = {
    project = "kittygram"
    env     = "production"
  }
}

# S3 бакет для хранения Terraform state создается отдельно
# Не включаем его в основную конфигурацию, так как он используется для backend 