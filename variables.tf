variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone to deploy resources"
  type        = string
  default     = "us-central1-a"
}

variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "oracle-linux"
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "machine_type" {
  description = "Machine type for the instances"
  type        = string
  default     = "e2-micro"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20
}

variable "instance_count" {
  description = "Number of instances to create in the MIG"
  type        = number
  default     = 5
}

variable "ssh_keys" {
  description = "SSH keys in the format 'username:ssh-rsa AAAAB3Nza...'"
  type        = string
  default     = ""
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default = {
    environment = "dev"
    managed_by  = "terraform"
  }
}

variable "enable_autoscaling" {
  description = "Enable autoscaling for the MIG"
  type        = bool
  default     = false
}

variable "min_replicas" {
  description = "Minimum number of replicas for autoscaling"
  type        = number
  default     = 3
}

variable "max_replicas" {
  description = "Maximum number of replicas for autoscaling"
  type        = number
  default     = 10
}

variable "cpu_utilization_target" {
  description = "Target CPU utilization for autoscaling"
  type        = number
  default     = 0.6
}
