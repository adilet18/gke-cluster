resource "google_container_cluster" "gke-cluster" {
  name                     = "primary-cluster"
  location                 = "us-central1-a"
  remove_default_node_pool = true
  network                  = google_compute_network.k8s_vpc.self_link
  subnetwork               = google_compute_subnetwork.private.self_link
  logging_service          = "logging.googleapis.com/kubernetes"
  monitoring_service       = "monitoring.googleapis.com/kubernetes"
  networking_mode          = "VPC_NATIVE"

  initial_node_count = 2
  node_locations = [
    "us-central1-b",
    "us-central1-c"
  ]

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods-range"
    services_secondary_range_name = "gke-service-range"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "192.168.2.0/28"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "109.201.189.6/32"
      display_name = "home-network"
    }
  }

  workload_identity_config {
    workload_pool = var.workload_identity_config
  }

  addons_config {
    http_load_balancing {
      disabled = true
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  release_channel {
    channel = "REGULAR"
  }
}




