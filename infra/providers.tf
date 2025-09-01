terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.84"
    }
  }
  required_version = ">= 1.0"

  backend "s3" {
    endpoint = "https://storage.yandexcloud.net"
    bucket = "kittygram-terraform-state-158160191213"
    region = "ru-central1"
    key    = "tf-state.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.default_zone
} 