terraform {
  required_providers {
    vagrant = {
      source  = "bmatcuk/vagrant"
      version = "~> 4.0"
    }
  }
}

provider "vagrant" {
  # O provedor Vagrant não precisa de blocos de configuração adicionais aqui.
  # Ele usa o Vagrantfile gerado pelo Terraform/Vagrant.
}

# Define o ambiente Vagrant para os servidores de aplicação
# O recurso correto é "vagrant_vm" e ele gerencia um diretório com um Vagrantfile.
resource "vagrant_vm" "app_servers_environment" {
  name            = "app-servers-development"
  # Aponta para o diretório que contém seu Vagrantfile
  # Assumindo que 'vagrant_env' é um subdiretório no seu módulo raiz do Terraform
  vagrantfile_dir = "${path.module}/vagrant_env"

  # Use um hash do Vagrantfile para forçar um 'reload' (atualização) em caso de mudanças.
  # Isso garante que o Terraform reaja a modificações dentro do Vagrantfile.
  env = {
    VAGRANTFILE_HASH = md5(file("${path.module}/vagrant_env/Vagrantfile"))
  }

  get_ports = true # Habilita a coleta de informações de portas encaminhadas para as saídas [1]
}

# Saídas para facilitar o Ansible
# O recurso vagrant_vm expõe as configurações SSH como uma lista.
# Você pode acessar os IPs privados através de 'ssh_config[*].host'.
output "app_server_ips" {
  description = "IPs privados dos servidores de aplicação para conectividade Ansible"
  value       = vagrant_vm.app_servers_environment.ssh_config[*].host
}

output "app_server_ssh_configs" {
  description = "Detalhes completos de conexão SSH para todos os servidores de aplicação"
  value       = vagrant_vm.app_servers_environment.ssh_config
  sensitive   = true # As chaves SSH privadas estão incluídas, então marque como sensível
}

output "app_server_forwarded_ports" {
  description = "Mapeamentos de portas encaminhadas para os servidores de aplicação (guest:host)"
  value       = vagrant_vm.app_servers_environment.ports
}