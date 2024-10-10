#=====================VPC============================

resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
}


resource "google_compute_network" "k8s_vpc" {
  name                            = "main"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false

  depends_on = [
    google_project_service.compute,
    google_project_service.container
  ]
}

#======================SUBNETS===========================

resource "google_compute_subnetwork" "private" {
  name                     = "my-private-subnet"
  ip_cidr_range            = "10.0.0.0/24"
  region                   = var.region
  network                  = google_compute_network.k8s_vpc.name
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "gke-pods-range"
    ip_cidr_range = "10.0.1.0/24"
  }

  secondary_ip_range {
    range_name    = "gke-service-range"
    ip_cidr_range = "10.0.2.0/24"
  }
}

#====================ROUTER============================

resource "google_compute_router" "router" {
  name    = "router"
  region  = var.region
  network = google_compute_network.k8s_vpc.id
}

#=======================NAT=============================

resource "google_compute_router_nat" "nat" {
  name                               = "nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ip_allocate_option             = "MANUAL_ONLY"

  subnetwork {
    name                    = google_compute_subnetwork.private.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  nat_ips = [google_compute_address.nat.self_link]
}

resource "google_compute_address" "nat" {
  name         = "nat"
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"

  depends_on = [google_project_service.compute]
}

#=====================FIREWALL-RULES==================

resource "google_compute_firewall" "k8s_firewalls" {
  for_each = var.firewall_rules

  name    = each.value.name
  network = google_compute_network.k8s_vpc.name

  allow {
    protocol = "tcp"
    ports    = each.value.allowed_ports
  }

  source_ranges = each.value.source_ranges
}
