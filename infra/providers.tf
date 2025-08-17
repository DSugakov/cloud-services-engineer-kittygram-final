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
    bucket = "kittygram-terraform-state"
    region = "ru-central1"
    key    = "tf-state.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    
    # Правильные credentials для Yandex Object Storage
    access_key = var.storage_access_key
    secret_key = var.storage_secret_key
  }
}

provider "yandex" {
  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.default_zone
} 