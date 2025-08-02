# Projeto TechLog - Configuração de Infraestrutura

Este projeto automatiza a configuração da infraestrutura do servidor TechLog, incluindo:

- Criação de grupos e usuários (desenvolvedores, operações e techlead)
- Configuração de permissões no diretório `/srv/app`
- Configuração e habilitação de cotas de disco para usuários em `/home`
- Instalação e configuração do servidor Apache para servir a página web em `/srv/app`
- Configuração de IP estático (ajustável no script)
- Configuração do firewall UFW para liberar apenas SSH (22) e HTTP (80)
- Instalação e habilitação do serviço Nginx para iniciar automaticamente

## Como usar

1. Faça o download/clonagem deste repositório.

2. Execute o script com permissões de superusuário (root):

```bash
sudo bash setup_infra.sh
