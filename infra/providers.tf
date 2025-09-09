terraform {
  required_version = ">= 1.3.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.109"
    }
  }

  backend "s3" {
    endpoints = { s3 = "https://storage.yandexcloud.net" }
    bucket    = "kittygram-terraform-state-158160191213"
    region    = "ru-central1"
    key       = "tf-state.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    skip_metadata_api_check     = true
    use_path_style              = true
  }
}

provider "yandex" {
  service_account_key = var.service_account_key != "" ? var.service_account_key : null
  service_account_key_file = var.service_account_key == "" ? var.sa_key_file : null
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}