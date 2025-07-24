variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

variable "service_account_key_file" {
  description = "Path to service account key file"
  type        = string
  default     = ""
}

variable "default_zone" {
  description = "Default availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "vm_image_family" {
  description = "VM image family"
  type        = string
  default     = "ubuntu-2404-lts"
}

variable "vm_cores" {
  description = "Number of CPU cores for VM"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "Memory size for VM in GB"
  type        = number
  default     = 4
}

variable "vm_disk_size" {
  description = "Disk size for VM in GB"
  type        = number
  default     = 20
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "storage_access_key" {
  description = "Storage access key for S3 bucket"
  type        = string
  default     = ""
}

variable "storage_secret_key" {
  description = "Storage secret key for S3 bucket"
  type        = string
  default     = ""
  sensitive   = true
} 