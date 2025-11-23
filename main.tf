# Configure the Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Create a VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "${var.name_prefix}-network"
  auto_create_subnetworks = false
}

# Create a subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.name_prefix}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

# Create a firewall rule to allow SSH
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.name_prefix}-allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["dev"]
}

# Create a firewall rule to allow HTTP
resource "google_compute_firewall" "allow_http" {
  name    = "${var.name_prefix}-allow-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["dev"]
}

# Get the latest Oracle Linux image
data "google_compute_image" "oracle_linux" {
  family  = "oracle-linux-8"
  project = "cloud-infrastructure-services"
}

# Create an instance template
resource "google_compute_instance_template" "oracle_template" {
  name_prefix  = "${var.name_prefix}-template-"
  machine_type = var.machine_type
  region       = var.region

  tags = ["dev"]

  disk {
    source_image = data.google_compute_image.oracle_linux.self_link
    auto_delete  = true
    boot         = true
    disk_size_gb = var.disk_size_gb
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet.id

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys               = var.ssh_keys != "" ? var.ssh_keys : null
    startup-script         = file("${path.module}/startup-script.sh")
  }

  lifecycle {
    create_before_destroy = true
  }

  labels = var.labels
}

# Create a health check
resource "google_compute_health_check" "autohealing" {
  name                = "${var.name_prefix}-healthcheck"
  check_interval_sec  = 30
  timeout_sec         = 10
  healthy_threshold   = 2
  unhealthy_threshold = 3

  tcp_health_check {
    port = "22"
  }
}

# Create Instance Group Manager (MIG)
resource "google_compute_instance_group_manager" "oracle_mig" {
  name               = "${var.name_prefix}-mig"
  base_instance_name = "${var.name_prefix}-instance"
  zone               = var.zone
  target_size        = var.instance_count

  version {
    instance_template = google_compute_instance_template.oracle_template.id
  }

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.id
    initial_delay_sec = 300
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create autoscaler (optional)
resource "google_compute_autoscaler" "oracle_autoscaler" {
  count  = var.enable_autoscaling ? 1 : 0
  name   = "${var.name_prefix}-autoscaler"
  zone   = var.zone
  target = google_compute_instance_group_manager.oracle_mig.id

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_period = 60

    cpu_utilization {
      target = var.cpu_utilization_target
    }
  }
}
