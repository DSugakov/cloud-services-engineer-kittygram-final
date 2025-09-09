output "vm_external_ip" {
  description = "External IP address of the VM"
  value       = local.vm_external_ip
}

output "vm_internal_ip" {
  description = "Internal IP address of the VM"
  value       = local.vm_internal_ip
}

output "vm_fqdn" {
  description = "Fully qualified domain name of the VM"
  value       = local.vm_fqdn
}

output "security_group_id" {
  description = "ID of the security group"
  value       = var.existing_security_group_id != "" ? var.existing_security_group_id : yandex_vpc_security_group.kittygram_sg[0].id
}

output "network_id" {
  description = "ID of the VPC network"
  value       = var.existing_network_id != "" ? var.existing_network_id : yandex_vpc_network.kittygram_network[0].id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = var.existing_subnet_id != "" ? var.existing_subnet_id : yandex_vpc_subnet.kittygram_subnet[0].id
}

output "kittygram_url" {
  description = "URL to access Kittygram application"
  value       = "http://${yandex_compute_instance.kittygram_vm.network_interface.0.nat_ip_address}:9000"
}

# S3 bucket создан вручную, поэтому output закомментирован
# output "s3_bucket_name" {
#   description = "Name of the S3 bucket for Terraform state"
#   value       = yandex_storage_bucket.terraform_state.bucket
# } 