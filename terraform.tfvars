# GCP Project Configuration
project_id = "gcp-terraform-demo-474514"
region     = "us-central1"
zone       = "us-central1-a"

# Resource Naming
name_prefix = "oracle-linux"

# Network Configuration
subnet_cidr = "10.0.1.0/24"

# Instance Configuration
machine_type   = "e2-medium"
disk_size_gb   = 20
instance_count = 5

# SSH Configuration (optional)
# Format: "username:ssh-rsa AAAAB3NzaC1yc2EAAAA..."
ssh_keys = ""

# Labels
labels = {
  environment = "dev"
  managed_by  = "terraform"
  os          = "oracle-linux"
}

# Autoscaling Configuration
enable_autoscaling     = false
min_replicas           = 3
max_replicas           = 10
cpu_utilization_target = 0.6
