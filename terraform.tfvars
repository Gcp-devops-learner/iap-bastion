project_id                   = "trinnex-service"
region                       = "us-central1"
cluster_name                 = "safer-cluster-iap-bastion01"
network_name                 = "shared-net"
subnet_name                  = "projects/trinnex-host1/regions/us-central1/subnetworks/us-central1"
host_project_id              = "trinnex-host1"
service_account_roles        = [
  "roles/resourcemanager.projectIamAdmin",
  "roles/iam.serviceAccountAdmin",
  "roles/compute.viewer",
  "roles/container.clusterAdmin",
  "roles/container.developer",
  "roles/storage.admin"
]
