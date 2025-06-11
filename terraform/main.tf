terraform {
  required_providers {
    vagrant = {
      source  = "bmatcuk/vagrant"
      version = "~> 4.0"
    }
  }
}

provider "vagrant" { }

resource "vagrant_vm" "app_servers_environment" {
  name            = "app-servers-development"
  vagrantfile_dir = "${path.module}/vagrant_env"
  env = {
    VAGRANTFILE_HASH = md5(file("${path.module}/vagrant_env/Vagrantfile"))
  }
  get_ports = true
}

output "app_server_ips" {
  description = "IPs privados dos servidores de aplicação para conectividade Ansible"
  value       = vagrant_vm.app_servers_environment.ssh_config[*].host
}

output "app_server_ssh_configs" {
  description = "Detalhes completos de conexão SSH para todos os servidores de aplicação"
  value       = vagrant_vm.app_servers_environment.ssh_config
  sensitive   = true
}

output "app_server_forwarded_ports" {
  description = "Mapeamentos de portas encaminhadas para os servidores de aplicação (guest:host)"
  value       = vagrant_vm.app_servers_environment.ports
}