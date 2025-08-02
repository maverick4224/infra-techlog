#!/bin/bash

echo "== Iniciando configuração da infraestrutura TechLog =="

# === 1. Atualização do sistema ===
echo "Atualizando pacotes..."
apt update && apt upgrade -y

# === 2. Criação de grupos e usuários ===
echo "Criando grupos..."
groupadd dev
groupadd suporte
groupadd rede

echo "Criando usuários..."
useradd -m -s /bin/bash dev -G dev
useradd -m -s /bin/bash sup -G suporte
useradd -m -s /bin/bash red -G rede

# === 3. Definição de senhas padrão ===
echo "Definindo senhas para os usuários..."
echo "dev:Senha123" | chpasswd
echo "sup:Senha123" | chpasswd
echo "red:Senha123" | chpasswd

# === 4. Criação de diretórios compartilhados ===
echo "Criando diretórios por grupo..."
mkdir -p /techlog/dev /techlog/suporte /techlog/rede

# === 5. Permissões nos diretórios ===
chown root:dev /techlog/dev
chown root:suporte /techlog/suporte
chown root:rede /techlog/rede

chmod 770 /techlog/dev
chmod 770 /techlog/suporte
chmod 770 /techlog/rede

# === 6. Instalação do Apache e Nginx ===
echo "Instalando Apache e Nginx..."
apt install -y apache2 nginx

# === 7. Criar e servir página simples com Apache ===
echo "Criando página index.html em /srv/app..."
mkdir -p /srv/app
cat > /srv/app/index.html <<EOF
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>TechLog - Página Inicial</title>
</head>
<body>
    <h1>Bem-vindo ao servidor TechLog!</h1>
    <p>Esta é uma página servida via Apache.</p>
</body>
</html>
EOF

echo "Configurando Apache para servir /srv/app..."
cat > /etc/apache2/sites-available/techlog.conf <<EOF
<VirtualHost *:80>
    DocumentRoot /srv/app
    <Directory /srv/app>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
</VirtualHost>
EOF

a2ensite techlog.conf
a2dissite 000-default.conf
systemctl reload apache2

# === 8. Ativando serviços Apache e Nginx ===
echo "Ativando serviços para iniciar com o sistema..."
systemctl enable apache2
systemctl enable nginx

# === 9. Configuração do firewall com UFW ===
echo "Configurando firewall com UFW..."
apt install -y ufw
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 8080/tcp
ufw --force enable

# === 10. Configurando Nginx para rodar na porta 8080 ===
echo "Configurando Nginx para rodar na porta 8080..."
sed -i 's/listen 80 default_server;/listen 8080 default_server;/g' /etc/nginx/sites-available/default
sed -i 's/listen \[::\]:80 default_server;/listen [::]:8080 default_server;/g' /etc/nginx/sites-available/default
systemctl restart nginx

# === 11. Configurar IP estático (ajustável) ===
echo "Configurando IP estático..."
IP_STATIC="192.168.1.100/24"
GATEWAY="192.168.1.1"
DNS="8.8.8.8"

cat > /etc/netplan/01-netcfg.yaml <<EOF
network:
  version: 2
  ethernets:
    eth0:
      addresses: [$IP_STATIC]
      gateway4: $GATEWAY
      nameservers:
        addresses: [$DNS]
EOF

netplan apply

# === 12. Configuração de cotas no /home ===
echo "Configurando cotas de disco no /home..."
apt install -y quota

if ! grep -q "usrjquota=quota.user,jqfmt=vfsv0" /etc/fstab; then
  sed -i '/\/home/ s/errors=remount-ro/errors=remount-ro,usrjquota=quota.user,jqfmt=vfsv0/' /etc/fstab
fi

mount -o remount /home
quotacheck -cum /home
quotaon /home

for user in dev sup red; do
  echo "Aplicando cota ao usuário $user..."
  setquota -u $user 204800 256000 0 0 /home
done

# === 13. Mostrar PID do Apache e comandos úteis ===
echo "PID do processo principal do Apache:"
systemctl status apache2 | grep "Main PID" || ps aux | grep apache2 | grep -v grep

echo "Use os comandos abaixo para verificar o status e consumo de recursos:"
echo "  systemctl status apache2"
echo "  ps -C apache2 -o pid,ppid,cmd,%mem,%cpu"
echo "  top -p \$(pidof apache2)"

echo "== Configuração concluída com sucesso! =="
