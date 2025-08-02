echo "== Iniciando configuração da infraestrutura TechLog =="

# 1. Atualização do sistema
echo "Atualizando pacotes..."
apt update && apt upgrade -y

# 2. Criação de grupos e usuários
echo "Criando grupos..."
groupadd dev
groupadd suporte
groupadd rede

echo "Criando usuários..."
useradd -m -s /bin/bash dev -G dev
useradd -m -s /bin/bash sup -G suporte
useradd -m -s /bin/bash red -G rede

# 3. Definição de senhas padrão (pode ser alterado depois)
echo "Definindo senhas para os usuários..."
echo "dev:Senha123" | chpasswd
echo "sup:Senha123" | chpasswd
echo "red:Senha123" | chpasswd

# 4. Criação de diretórios compartilhados
echo "Criando diretórios por grupo..."
mkdir -p /techlog/dev /techlog/suporte /techlog/rede

# 5. Permissões nos diretórios
chown root:dev /techlog/dev
chown root:suporte /techlog/suporte
chown root:rede /techlog/rede

chmod 770 /techlog/dev
chmod 770 /techlog/suporte
chmod 770 /techlog/rede

# 6. Instalação do Apache e Nginx
echo "Instalando Apache e Nginx..."
apt install -y apache2 nginx

# 7. Habilitando serviços
echo "Ativando serviços para iniciar com o sistema..."
systemctl enable apache2
systemctl enable nginx

# 8. Configuração de firewall básica
echo "Configurando firewall com UFW..."
apt install -y ufw
ufw allow OpenSSH
ufw allow 'Apache Full'
ufw allow 'Nginx Full'
ufw enable
