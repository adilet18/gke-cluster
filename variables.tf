variable "region" {
  default = "us-central1"
}

variable "project" {
  default = "playground-s-11-e32c89a9"
}

variable "workload_identity_config" {
  default = "playground-s-11-e32c89a9.svc.id.goog"
}

variable "tags" {
  default = {
    environment = "prod"
    project     = "final-project"
    node_pool1  = "general"
    node_pool2  = "spot"
  }
}

variable "auth-scopes" {
  description = "OAuth scopes for the service account."
  type        = list(string)
  default     = ["https://www.googleapis.com/auth/cloud-platform"]
}

variable "firewall_rules" {
  type = map(object({
    name          = string
    allowed_ports = list(string)
    source_ranges = list(string)
  }))

  default = {
    allow_frontend_http = {
      name          = "allow-frontend-http"
      allowed_ports = ["80", "443"]
      source_ranges = ["0.0.0.0/0"]
    },
    allow_frontend_to_backend = {
      name          = "allow-frontend-to-backend"
      allowed_ports = ["3000"]
      source_ranges = ["10.0.0.0/24"]
    },
    allow_backend_to_db = {
      name          = "allow-backend-to-db"
      allowed_ports = ["5432"]
      source_ranges = ["10.0.0.0/24"]
    },
    allow_ssh = {
      name          = "allow-ssh"
      allowed_ports = ["22"]
      source_ranges = ["109.201.189.6/32"]
    },
    allow_internal_k8s = {
      name          = "allow-internal-k8s"
      allowed_ports = ["0-65535"]
      source_ranges = ["10.0.0.0/24"]
    }
  }
}
