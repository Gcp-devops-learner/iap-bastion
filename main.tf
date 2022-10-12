locals {
  bastion_name = format("%s-bastion", var.cluster_name)
  bastion_zone = format("%s-a", var.region)
}

data "template_file" "startup_script" {
  template = <<-EOF
  sudo apt-get update -y
  sudo apt install -y wget
  sudo apt-get install -y git
  sudo apt-get -y update && sudo apt-get install -y gnupg software-properties-common && \
  wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg 
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt -y update && sudo apt-get  -y install terraform  
  sudo apt-get install -y kubectl
  EOF
}

module "bastion" {
  source  = "terraform-google-modules/bastion-host/google"
  version = "~> 5.0"

  network        = var.network_name
  subnet         = var.subnet_name
  project        = var.project_id
  host_project   = var.host_project_id
  name           = local.bastion_name
  zone           = local.bastion_zone
  image_project  = "debian-cloud"
  machine_type   = "g1-small"
  startup_script = data.template_file.startup_script.rendered
  shielded_vm    = "false"
  service_account_roles = var.service_account_roles
  scopes                = var.scopes
}

resource "google_project_iam_member" "editor" {
  project = var.host_project_id
  role    = "roles/editor"
  member = "serviceAccount:${module.bastion.service_account}"
  depends_on = [
    module.bastion
  ]
}

resource "google_project_iam_member" "iamadmin" {
  project = var.host_project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member = "serviceAccount:${module.bastion.service_account}"
  depends_on = [
    module.bastion
  ]
}