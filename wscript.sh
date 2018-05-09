#!/bin/bash

updateServer(){
    printf '***********************Updating OS********************** \n'
    sudo apt-get update
}

exportLang() {
    printf '***********************Exporting LANG******************* \n'
    export LANG="en_US.UTF-8"
    export LC_ALL="en_US.UTF-8"
    export LC_CTYPE="en_US.UTF-8"
}

installPython(){
    printf '**********************Installing Python 3.6 and dependancies***************** \n'
    sudo apt-get install -y python=3.6
    sudo apt-get install -y python3-pip  
    sudo apt-get install uwsgi-plugin-python
}

installWsgi(){
    printf '*********************Setting up wsgi server************************** \n'
    sudo pip3 install uwsgi

}
installNginx(){
    printf "*********************Installing Nginx******************************* \n"
    sudo apt-get install nginx
}
#create Virtualenv
setupVirtualenv(){
    printf "******************Setting up virtualenv******************* \n"
    sudo apt-get install -y virtualenv
    virtualenv -p /usr/bin/python3 demoenv
}

cloneRepo(){
    printf "*******************Cloning git Repo******************* \n"
    git clone https://github.com/anyric/Yummy-Recipes-Api.git
}

activateVirtualenv(){
    printf "*****************Activation virtualenv**************** \n"
    #activate virtualenv
    source demoenv/bin/activate

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
    """module to run app"""
    from apps import app

    if __name__ == "__main__":
        app.run(host="0.0.0.0", threaded=True)
EOF'
}

createWsgiEntryPoint(){
    printf "*****************Creating Wsgi Entry Point*************** \n"

    sudo bash -c 'cat <<EOF> ./wsgi.py
    from app import app

    if __name__== "__main__":
        app.run()
EOF'
}

startNginx(){
    printf "******************Starting Nginx************************** \n"
    sudo systemctl start nginx
}

configureNginx(){
    printf "******************Configuring Nginx*********************** \n"
    sudo rm -rf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

    sudo bash -c 'cat <<EOF> /etc/nginx/sites-available/default
    server {
            listen 80;
            location / {
                    proxy_pass http://127.0.0.1:8000/;
                    proxy_set_header HOST $host;
                    proxy_set_header X-Forwarded-Proto $scheme;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            }
    }
EOF'
}

restartNginx(){
    printf "*******************Restarting Nginx************************ \n"
    sudo systemctl restart nginx
}

configureWsgi(){
    printf "******************Configuring wsgi************************\n"

    sudo bash -c 'cat <<EOF> ./wsgi_config.ini
    [uwsgi]
    socket = 0.0.0.0:5000
    wsgi-file = ./wsgi.py
    processes = 5
    master = true
    threads = 2
EOF'
}
startApp(){
    printf "*******************Starting App*************************** \n"
    #uwsgi --socket 0.0.0.0:5000 --protocol=http -w wsgi:app # add & at the end here to run in background
    uwsgi  wsgi_config.ini
}

run(){
    updateServer
    exportLang
    installPython
    installWsgi
    installNginx
    setupVirtualenv
    cloneRepo
    activateVirtualenv
    setupProjectDependancies
    setupHostIP
    createWsgiEntryPoint
    startNginx
    configureNginx
    restartNginx
    configureWsgi
    startApp
}

run

