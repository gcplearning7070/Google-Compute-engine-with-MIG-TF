output "network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.vpc_network.name
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "instance_group_manager_name" {
  description = "Name of the Managed Instance Group"
  value       = google_compute_instance_group_manager.oracle_mig.name
}

output "instance_group_manager_id" {
  description = "ID of the Managed Instance Group"
  value       = google_compute_instance_group_manager.oracle_mig.id
}

output "instance_template_name" {
  description = "Name of the instance template"
  value       = google_compute_instance_template.oracle_template.name
}

output "instance_group_url" {
  description = "URL of the instance group"
  value       = google_compute_instance_group_manager.oracle_mig.instance_group
}

output "health_check_name" {
  description = "Name of the health check"
  value       = google_compute_health_check.autohealing.name
}

output "oracle_linux_image" {
  description = "Oracle Linux image used"
  value       = data.google_compute_image.oracle_linux.self_link
}
