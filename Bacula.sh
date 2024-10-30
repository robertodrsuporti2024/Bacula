#!/bin/bash

# Atualize o sistema
sudo apt update && sudo apt upgrade -y

# Adicione o repositório do Bacula Community para Debian 12
wget -O- https://www.bacula.org/downloads/Bacula-4096-Distribution-Verification-key.asc | sudo apt-key add -
echo "deb https://www.bacula.org/packages/11/debian/ bookworm main" | sudo tee /etc/apt/sources.list.d/bacula.list

# Atualize os repositórios para incluir o Bacula Community
sudo apt update

# Instale o Bacula e o MariaDB
sudo apt install -y bacula-mysql mariadb-server

# Inicie e habilite o MariaDB
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Configuração do banco de dados
DB_ROOT_PASS="Dr5up0rt1!@#$%"    # Defina uma senha forte para o MariaDB root
BACULA_DB="bacula"
BACULA_USER="bacula"
BACULA_PASS="Dr5up0rt1!@#$%"     # Defina uma senha para o usuário do Bacula

# Defina a senha de root para o MariaDB e crie o banco de dados e usuário do Bacula
sudo mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('$DB_ROOT_PASS'); FLUSH PRIVILEGES;"
sudo mysql -u root -p$DB_ROOT_PASS -e "CREATE DATABASE $BACULA_DB;"
sudo mysql -u root -p$DB_ROOT_PASS -e "CREATE USER '$BACULA_USER'@'localhost' IDENTIFIED BY '$BACULA_PASS';"
sudo mysql -u root -p$DB_ROOT_PASS -e "GRANT ALL PRIVILEGES ON $BACULA_DB.* TO '$BACULA_USER'@'localhost';"
sudo mysql -u root -p$DB_ROOT_PASS -e "FLUSH PRIVILEGES;"

# Configure o Bacula para usar o banco de dados MariaDB
sudo /usr/lib/bacula/make_mysql_tables -u $BACULA_USER -p$BACULA_PASS -d $BACULA_DB
sudo /usr/lib/bacula/grant_mysql_privileges -u $BACULA_USER -p$BACULA_PASS

# Atualizar o arquivo de configuração do Bacula Director com as credenciais do banco de dados
sudo sed -i "s/dbpassword = .*/dbpassword = \"$BACULA_PASS\"/" /etc/bacula/bacula-dir.conf

# Reinicie e habilite os serviços do Bacula
sudo systemctl restart bacula-director
sudo systemctl restart bacula-sd
sudo systemctl restart bacula-fd
sudo systemctl enable bacula-director
sudo systemctl enable bacula-sd
sudo systemctl enable bacula-fd

echo "Instalação do Bacula Community concluída!"
echo "Banco de dados Bacula criado com nome '$BACULA_DB', usuário '$BACULA_USER', e senha '$BACULA_PASS'."
