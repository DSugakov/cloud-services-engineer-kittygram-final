output "vm_external_ip" {
  description = "External IP address of the VM"
  value       = yandex_compute_instance.kittygram_vm.network_interface.0.nat_ip_address
}

output "vm_internal_ip" {
  description = "Internal IP address of the VM"
  value       = yandex_compute_instance.kittygram_vm.network_interface.0.ip_address
}

output "vm_fqdn" {
  description = "Fully qualified domain name of the VM"
  value       = yandex_compute_instance.kittygram_vm.fqdn
}

output "security_group_id" {
  description = "ID of the security group"
  value       = yandex_vpc_security_group.kittygram_sg.id
}

output "network_id" {
  description = "ID of the VPC network"
  value       = yandex_vpc_network.kittygram_network.id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = yandex_vpc_subnet.kittygram_subnet.id
}

output "kittygram_url" {
  description = "URL to access Kittygram application"
  value       = "http://${yandex_compute_instance.kittygram_vm.network_interface.0.nat_ip_address}:9000"
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = yandex_storage_bucket.terraform_state.bucket
} 