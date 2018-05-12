#!/bin/bash

updateServer(){
    printf '***********************Updating OS********************** \n'
    sudo apt-get update
}

exportLang() {
    printf '***********************Exporting LANG Variables******************* \n'
    export LANG="en_US.UTF-8"
    export LC_ALL="en_US.UTF-8"
    export LC_CTYPE="en_US.UTF-8"
}

installPython(){
    printf '**********************Installing Python 3.6 and dependancies***************** \n'
    sudo apt-get install -y python=3.6
    sudo apt-get install -y python3-pip  
}

installNginxGunicorn(){
    printf "*********************Installing Nginx******************************* \n"
    sudo apt-get install -y nginx gunicorn
}

setupVirtualenv(){
    printf "******************Setting up virtualenv******************* \n"
    sudo apt-get install -y virtualenv
    virtualenv -p /usr/bin/python3 my_env
}

cloneRepo(){
    printf "*******************Cloning git Repo******************* \n"
    git clone https://github.com/anyric/Yummy-Recipes-Api.git
}

activateVirtualenv(){
    printf "*****************Activation virtualenv**************** \n"
    source my_env/bin/activate
}

setupProjectDependancies(){
    printf "*******************Installing requirements.txt************* \n"
    cd Yummy-Recipes-Api
    pip install -r requirements.txt
}

setupHostIP(){
    printf "****************Configuring Host Ip Address***************** \n"
    sudo rm -rf app.py
    sudo bash -c 'cat <<EOF> ./app.py
from apps import app

if __name__ == "__main__":
    app.run(host="0.0.0.0", threaded=True)
EOF'
}

configureNginx(){
    printf "******************Configuring Nginx*********************** \n"
    sudo rm -rf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
    sudo rm -rf /etc/nginx/sites-available/yummy /etc/nginx/sites-enabled/yummy
    sudo bash -c 'cat <<EOF> /etc/nginx/sites-available/yummy
server {
        listen 80 default_server;
        listen [::]:80;
        server_name anyric.tk www.anyric.tk;

        location / {
            proxy_pass http://unix:/run/gunicorn/socket;
        }
}
EOF'
    sudo ln -s /etc/nginx/sites-available/yummy /etc/nginx/sites-enabled
    sudo systemctl enable nginx.service
    sudo systemctl start nginx
    sudo ufw allow 'Nginx Full'
    sudo ufw delete allow 'Nginx HTTP'
}

configureSSH(){
    printf "********************Configuring SSH****************** \n"
    sudo service nginx stop
    sudo add-apt-repository ppa:certbot/certbot
    sudo apt-get update
    sudo apt-get install -y python-certbot-nginx
    sudo certbot --nginx
}

configureSystemd(){
    printf "***********************Configuring Systemd*************** \n"
    sudo bash -c 'cat <<EOF> /etc/systemd/system/gunicorn.service
[Unit]
Description=Gunicorn instance to serve yummy recipe
Requires=gunicorn.socket
After=network.target

[Service]
PIDFile=/run/gunicorn/pid
User=ubuntu
Group=www-data
RuntimeDirectory=gunicorn
WorkingDirectory=/home/ubuntu/Yummy-Recipes-Api
Environment="PATH=/home/ubuntu/Yummy-Recipes-Api/my_env/bin"
ExecStart=/home/ubuntu/Yummy-Recipes-Api/my_env/bin/gunicorn --workers 4 --bind unix:gunicorn.sock -m 007 app:app
ExecStart=/usr/bin/gunicorn --pid /run/gunicorn/pid --bind unix:/run/gunicorn/socket app:app
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target

EOF'

    sudo bash -c 'cat <<EOF> /etc/systemd/system/gunicorn.socket
[Unit]
Description=gunicorn socket

[Socket]
ListenStream=/run/gunicorn/socket

[Install]
WantedBy=sockets.target

EOF'

    sudo bash -c 'cat <<EOF> /etc/systemd/system/gunicorn.conf
d /run/gunicorn 0755 ubuntu www-data -
EOF'
    sudo systemctl enable gunicorn.socket
    sudo systemctl start gunicorn.socket
}
exportDatabaseUrl(){
    printf "********************Exporting DATABASE_URL****************** \n"
    export DATABASE_URL="postgres://postgres:postgres1234@postgresdb.cztrtf3jyreo.us-east-2.rds.amazonaws.com:5432/yummy_api"
}

startApp(){
    printf "*******************Starting App*************************** \n"
    sudo systemctl start nginx
    sudo systemctl start yummy
    sudo systemctl enable yummy
}

run(){
    updateServer
    exportLang
    setupVirtualenv
    activateVirtualenv
    installPython
    installNginxGunicorn
    cloneRepo
    setupProjectDependancies
    setupHostIP
    configureNginx
    configureSSH
    configureSystemd
    exportDatabaseUrl
    startApp
}

run

