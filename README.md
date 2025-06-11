PoC: Automação e Infraestrutura como Código (IaC) com Terraform, Ansible e Docker
Este projeto é uma Prova de Conceito (PoC) que demonstra a sinergia entre Terraform, Ansible e Docker para provisionar e configurar uma aplicação web multicamadas. A PoC configura um ambiente local com uma Máquina Virtual (VM) que hospeda um gateway Nginx e múltiplas instâncias de um serviço Express.js.

Sumário do Projeto
Terraform: Provisiona uma VM Ubuntu (via Vagrant/VirtualBox) no ambiente local.
Ansible: Configura a VM (instala Docker e Docker Compose, copia arquivos de aplicação).
Docker: Executa a aplicação em contêineres.
Nginx: Atua como gateway e balanceador de carga.
Express.js: Serviço web de exemplo.
Por que Terraform e Ansible Juntos?
Muitos perguntam por que usar duas ferramentas em vez de apenas uma. A resposta reside na especialização e no nível de abstração de cada uma:

Terraform (Provisionamento de Infraestrutura):

Utilidade: É especialista em criar, modificar e destruir recursos de infraestrutura. Ele se comunica com APIs de provedores (nuvem, virtualização local, etc.) para levantar a "estrutura" básica do seu ambiente (VMs, redes, discos).
Abordagem: Declarativa - você descreve o estado final desejado da sua infraestrutura (ex: "quero uma VM com 2GB de RAM e esse IP"). O Terraform descobre os passos para chegar lá.
Neste Projeto: Usado para criar a VM Ubuntu no VirtualBox (através do Vagrant).
Ansible (Gerenciamento de Configuração e Automação):

Utilidade: É especialista em configurar sistemas operacionais, instalar softwares, gerenciar serviços e implantar aplicações dentro da infraestrutura já provisionada. Ele se comunica via SSH (ou WinRM) com os servidores.
Abordagem: Também é declarativa (via playbooks que descrevem o estado desejado do sistema), mas opera em um nível mais "detalhado" de automação do SO.
Neste Projeto: Usado para transformar a VM Ubuntu "limpa" em um host Docker pronto para rodar a aplicação (instalando Docker, Docker Compose, copiando arquivos e executando o docker compose up).
Juntos, eles oferecem uma solução completa de IaC: O Terraform levanta a casa, e o Ansible decora e move os móveis para dentro dela. Isso garante que sua infraestrutura seja replicável do "zero" até a aplicação rodando, com consistência e automação em todas as camadas.

Pré-requisitos
Certifique-se de que os seguintes softwares estão instalados no seu ambiente antes de iniciar:

VirtualBox: Ferramenta de virtualização.
Instalação: Baixe e instale o .exe no Windows.
Verificação: No Terminal do Windows (CMD/PowerShell), execute VBoxManage --version. Se der erro, adicione C:\Program Files\Oracle\VirtualBox\ ao seu PATH do Windows.
Vagrant: Ferramenta para gerenciar VMs de forma programática sobre VirtualBox.
Instalação: Baixe e instale o .msi no Windows.
Verificação: No Terminal do Windows, execute vagrant --version.
Terraform: Ferramenta de IaC para provisionamento.
Instalação: Baixe o binário para Windows e adicione a pasta ao seu PATH do Windows.
Verificação: No Terminal do Windows, execute terraform --version.
Ansible: Ferramenta de automação e gerenciamento de configuração.
Instalação: Instale DENTRO do WSL (Windows Subsystem for Linux).
Linux/WSL: sudo apt update && sudo apt install ansible ou pip install ansible.
Verificação: No Terminal do WSL, execute ansible --version.
WSL (Windows Subsystem for Linux): Para rodar o Ansible e acessar o ambiente Linux.
Instalação: Siga as instruções da Microsoft para instalar o WSL e uma distribuição Linux (ex: Ubuntu).
Verificação: No Terminal do Windows, execute wsl -l -v.
Estrutura do Projeto
poc-full-iac/
├── terraform/
│   ├── .terraform/            # Gerado - IGNORAR
│   ├── .terraform.lock.hcl    # Gerado (pode ignorar ou versionar)
│   ├── vagrant_env/
│   │   ├── .vagrant/          # Gerado - IGNORAR (contém chaves SSH, VMs)
│   │   └── Vagrantfile        # Definição da VM para o Vagrant
│   ├── main.tf                # Configuração do Terraform
│   └── terraform.tfstate      # Gerado - NUNCA VERSIONAR
├── ansible/
│   ├── files/                 # Arquivos copiados para a VM
│   │   ├── express-service-1/
│   │   │   ├── Dockerfile
│   │   │   ├── app.js
│   │   │   └── package.json
│   │   ├── nginx/
│   │   │   └── nginx.conf
│   │   └── docker-compose.yml
│   ├── ansible.cfg            # Configuração do Ansible
│   ├── inventory.ini          # Inventário de hosts do Ansible
│   └── setup-vms.yml          # Playbook Ansible
└── .gitignore                 # Arquivo de ignorados do Git
└── README.md                  # Este arquivo
Observação: Todo o projeto (poc-full-iac) reside no seu sistema de arquivos do Windows (ex: D:\dev\poc-full-iac). Isso é crucial para evitar problemas de "state lock" e acesso a arquivos quando o Terraform (no Windows) interage com o ambiente do WSL.

Como Rodar a PoC
Siga os passos abaixo na ordem. É fundamental prestar atenção se o comando deve ser executado no Terminal do Windows ou no Terminal do WSL.

0. Configurações Iniciais (Uma única vez)
Desabilitar DHCP na Rede Host-Only do VirtualBox:

Abra o Gerenciador do VirtualBox.
Vá em Arquivo (File) > Gerenciador de Rede do Host (Host Network Manager).
Selecione a rede "VirtualBox Host-Only Ethernet Adapter" (geralmente vboxnet0).
Clique no botão Propriedades (ícone da engrenagem).
Na aba Servidor DHCP, DESMARQUE a caixa Habilitar Servidor. Clique em Aplicar e OK.
Feche o Gerenciador do VirtualBox completamente.
Reinicie seu computador inteiro. Isso é fundamental para que as alterações de rede do VirtualBox sejam aplicadas corretamente.
Configuração de Permissões de Chave SSH no WSL:

Após o terraform apply (que será feito no passo 1.4) criar a chave SSH, você precisará copiá-la para o sistema de arquivos nativo do WSL.
Abra o Terminal do WSL (Ubuntu).
Crie a pasta .ssh se ela não existir: mkdir -p ~/.ssh
A chave privada da VM será criada em D:\dev\poc-full-iac\terraform\vagrant_env\.vagrant\machines\app-server-1\virtualbox\private_key. Copie-a para o WSL:
Bash

cp /mnt/d/dev/poc-full-iac/terraform/vagrant_env/.vagrant/machines/app-server-1/virtualbox/private_key ~/.ssh/vagrant_app_server_1_key
Defina as permissões corretas para a chave no WSL:
Bash

chmod 600 ~/.ssh/vagrant_app_server_1_key
Edite o D:\dev\poc-full-iac\ansible\inventory.ini para usar o novo caminho da chave:
Ini, TOML

# ... (apenas a parte relevante)
app-server-1 ansible_host=192.168.56.101 ansible_port=22 ansible_user=vagrant ansible_ssh_private_key_file=~/.ssh/vagrant_app_server_1_key ansible_python_interpreter=/usr/bin/python3
# ...
Esta etapa será crucial antes de rodar o Ansible.
1. Provisionar a VM com Terraform (No Terminal do Windows)
Este passo criará sua máquina virtual Ubuntu.

Abra um novo Terminal do Windows (PowerShell ou CMD).
Navegue até a pasta terraform do seu projeto:
PowerShell

Set-Location D:\dev\poc-full-iac\terraform\
Comandos de Limpeza (Essenciais antes de provisionar):
PowerShell

# Destrói qualquer VM gerenciada por Terraform/Vagrant anteriormente
terraform destroy --auto-approve
# Limpa o diretório de estado do Vagrant (contém VMs, chaves SSH)
Remove-Item -Recurse -Force .\vagrant_env\.vagrant -ErrorAction SilentlyContinue
# Limpa os arquivos de estado e cache do Terraform
Remove-Item .terraform.tfstate -ErrorAction SilentlyContinue
Remove-Item .terraform.tfstate.backup -ErrorAction SilentlyContinue
Remove-Item .terraform.tfstate.lock.info -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .terraform -ErrorAction SilentlyContinue
Inicialize o Terraform:
PowerShell

terraform init
Aplique o Plano (cria a VM):
PowerShell

terraform apply --auto-approve
Observe as janelas do VirtualBox que se abrem. A VM (app-server-1) deve iniciar e bootar até a tela de login.
O Terraform deve finalizar com "Apply complete! Resources: 1 added, 0 changed, 0 destroyed."
2. Configurar a VM com Ansible (No Terminal do WSL)
Este passo instalará o Docker, o Docker Compose e implantará sua aplicação na VM.

Abra um novo Terminal do WSL (Ubuntu).
Navegue até a pasta ansible do seu projeto:
Bash

cd /mnt/d/dev/poc-full-iac/ansible/
Execute o Playbook Ansible:
Bash

ansible-playbook -i inventory.ini setup-vms.yml
Observe a saída. Todas as tarefas devem ser ok ou changed, e o PLAY RECAP deve mostrar failed=0 e unreachable=0.
3. Verificar a Aplicação (No Navegador do Windows)
Após o Ansible concluir com sucesso:

Abra seu navegador no Windows.
Acesse: http://localhost:8080
Você deve ver a mensagem "Hello from Express Service 1 on host [ID do contêiner]! Time: [timestamp]".
Recarregue a página várias vezes (F5 ou Ctrl+R) para ver o ID do contêiner mudar, demonstrando o balanceamento de carga entre as réplicas do Express Service 1.
4. Limpeza (Após a Demonstração)
Para desligar e remover a VM e liberar recursos:

Abra um Terminal do Windows (PowerShell ou CMD).
Navegue até a pasta terraform:
PowerShell

Set-Location D:\dev\poc-full-iac\terraform\
Destrua a infraestrutura:
PowerShell

terraform destroy --auto-approve