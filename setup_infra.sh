!/bin/bash

echo "== Iniciando configuração da infraestrutura TechLog =="

# 1. Atualização do sistema
echo "[1/10] Atualizando pacotes..."
apt update && apt upgrade -y

# 2. Criação de grupos
echo "[2/10] Criando grupos..."
groupadd desenvolvedores
groupadd operacoes

# 3. Criação de usuários e associação a grupos
echo "[3/10] Criando usuários..."
useradd -m -s /bin/bash dev1 -G desenvolvedores
useradd -m -s /bin/bash dev2 -G desenvolvedores
useradd -m -s /bin/bash ops1 -G operacoes
useradd -m -s /bin/bash ops2 -G operacoes
useradd -m -s /bin/bash techlead -G desenvolvedores,operacoes
# 4. Definição de senhas
echo "[4/10] Definindo senhas..."
echo "dev1:Senha123" | chpasswd
echo "dev2:Senha123" | chpasswd
echo "ops1:Senha123" | chpasswd
echo "ops2:Senha123" | chpasswd
echo "techlead:Senha123" | chpasswd

# 5. Criação do diretório da aplicação
echo "[5/10] Criando diretório da aplicação /srv/app..."
mkdir -p /srv/app

# 6. Permissões e grupos no diretório
echo "[6/10] Ajustando permissões em /srv/app..."
chown root:desenvolvedores /srv/app
chmod 770 /srv/app
setfacl -m g:operacoes:rx /srv/app
chmod o-rwx /srv/app

# 7. Habilitar cotas de disco
echo "[7/10] Habilitando cotas de disco em /home..."
apt install -y quota
mount -o remount,usrquota,grpquota /home
quotacheck -cum /home
quotaon /home

for user in dev1 dev2 ops1 ops2 techlead; do
  setquota -u $user 200000 250000 0 0 /home
done

# 8. Instalação do Apache e Nginx
echo "[8/10] Instalando Apache e Nginx..."
apt install -y apache2 nginx

# 9. Configurando Apache para servir /srv/app
echo "[9/10] Configurando Apache..."
echo "<VirtualHost *:80>
    DocumentRoot /srv/app
<Directory /srv/app>
        Require all granted
    </Directory>
</VirtualHost>" > /etc/apache2/sites-available/000-default.conf

# Página HTML de teste
echo "<h1>Bem-vindo à TechLog</h1>" > /srv/app/index.html

# 10. Configurar Nginx na porta 8080
echo "[10/10] Configurando Nginx na porta 8080..."
sed -i 's/listen 80 default_server;/listen 8080 default_server;/g' /etc/nginx/s>
sed -i 's/listen \[::\]:80 default_server;/listen [::]:8080 default_server;/g' >

# Habilitar serviços
systemctl enable apache2
systemctl enable nginx
systemctl restart apache2
systemctl restart nginx

# Firewall
echo "[Firewall] Instalando e configurando UFW..."
apt install -y ufw
ufw allow 22
ufw allow 80
ufw enable

echo "== Configuração concluída com sucesso! =="



