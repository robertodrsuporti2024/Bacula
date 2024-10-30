#!/bin/bash

# Atualize o sistema
sudo apt update && sudo apt upgrade -y

# Adicione o repositório do Bacula/Baculum para Debian 12
wget -O- https://www.bacula.org/downloads/Bacula-4096-Distribution-Verification-key.asc | sudo apt-key add -
echo "deb https://www.bacula.org/packages/11/debian/ bookworm main" | sudo tee /etc/apt/sources.list.d/bacula.list

# Atualize os repositórios para incluir o Baculum
sudo apt update

# Instale o Apache, PHP e o Baculum
sudo apt install -y apache2 php libapache2-mod-php php-mysql baculum-common baculum-api baculum-web

# Habilite os módulos necessários do Apache e reinicie o serviço
sudo a2enmod rewrite
sudo systemctl restart apache2

# Configure permissões para o Baculum API e Baculum Web
sudo usermod -aG bacula www-data
sudo chown -R www-data:bacula /etc/bacula
sudo chown -R www-data:bacula /opt/bacula/bin

# Habilite e inicie os serviços Baculum
sudo systemctl enable baculum-api baculum-web
sudo systemctl start baculum-api baculum-web

# Firewall: permita o acesso às portas 9095 (API) e 9096 (Web) do Baculum, se o firewall estiver ativo
sudo ufw allow 9095
sudo ufw allow 9096

echo "Instalação do Baculum concluída!"
echo "Acesse a interface web do Baculum em http://<seu_ip>:9096 e a API em http://<seu_ip>:9095"
