provider "google" {
 project     = "lustrous-baton-384014"
 alias = "impersonation"
 region = "us-central1"
 scopes = [
   "https://www.googleapis.com/auth/cloud-platform"
 ]
}

data "terraform_remote_state" "base" {
  backend = "gcs"
  config = {
    bucket = "seanpal-bucket-df"
    prefix  = "prod"

  }
}

####
# VPC
resource "google_compute_network" "project_vpc" {
  project                 = "lustrous-baton-384014"
  name                    = "project-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}


# public Subnet
resource "google_compute_subnetwork" "public" {
  project     = "lustrous-baton-384014"
  region = "us-central1"
  name          = "project-public-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.project_vpc.id
}

# Private Subnet
resource "google_compute_subnetwork" "private" {
  name          = "project-private-subnet"
  ip_cidr_range = "10.0.1.0/24"
  project     = "lustrous-baton-384014"
  region        = "us-central1"
  network       = google_compute_network.project_vpc.id
}

# Cloud Router
resource "google_compute_router" "router" {
  name    = "project-router"
  project     = "lustrous-baton-384014"
  region = "us-central1"
  network = google_compute_network.project_vpc.id
  bgp {
    asn            = 64514
    advertise_mode = "CUSTOM"
  }
}
