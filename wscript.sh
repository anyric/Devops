#!/bin/bash

updateServer(){
    """update OS"""
    printf "***********************Updating OS********************** \n"
    sudo apt-get update
}

exportLang() {
    """export lan variables"""
    printf "***********************Exporting LANG******************* \n"
    export LANG="en_US.UTF-8"
    export LC_ALL="en_US.UTF-8"
    export LC_CTYPE="en_US.UTF-8"
}

installPython(){
    """install python3.6 and dependancies"""
    printf "**********************Installing Python 3.6 and dependancies***************** \n"
    sudo apt-get install -y python=3.6
    sudo apt-get install -y python3-pip  
    sudo apt-get install uwsgi-plugin-python
}

installWsgi(){
    """install and configure wsgi server"""
    printf "*********************Setting up wsgi server************************** \n"
    pip install uwsgi

}
installNginx(){
    """Install and config Nginx"""
    printf "*********************Installing Nginx******************************* \n"
    sudo apt-get install nginx
}
#create Virtualenv
setupVirtualenv(){
    """install virtualenv"""
    printf "******************Setting up virtualenv******************* \n"
    sudo apt-get install -y virtualenv
    virtualenv -p /usr/bin/python3 demoenv
}

cloneRepo(){
    """Clone project repo from git"""
    printf "*******************Cloning git Repo******************* \n"
    git clone https://github.com/anyric/Yummy-Recipes-Api.git
}

activateVirtualenv(){
    """Activate virtualenv"""
    printf "*****************Activation virtualenv**************** \n"
    #activate virtualenv
    source demoenv/bin/activate

}

setupProjectDependancies(){
    """Enter project folder and install requirements"""
    printf "*******************Installing requirements.txt************* \n"
    cd Yummy-Recipes-Api
    pip install -r requirements.txt
}

setupHostIP(){
    """Configure host ip address"""
    printf "****************Configuring Host Ip Address***************** \n"
    echo configuring host ip
    sudo rm -rf app.py
    sudo bash -c 'cat <<EOF> ./app.py
    """module to run app"""
    from apps import app

    if __name__ == "__main__":
        app.run(host="0.0.0.0", threaded=True)
    EOF'
}

createWsgiEntryPoint(){
    """Create Wsgi Entry Point"""
    printf "*****************Creating Wsgi Entry Point*************** \n"
    echo creating wsgi entry point
    sudo bash -c 'cat <<EOF> ./wsgi.py
    """module for wsgi entry point"""
    from app import app

    if __name__== "__main__":
        app.run()
    EOF'
}

startNginx(){
    """Stating Nginx"""
    printf "******************Starting Nginx************************** \n"
    sudo systemctl start nginx
}

configureNginx(){
    """Configuring Nginx"""
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
    """Restarting Nginx"""
    printf "*******************Restarting Nginx************************ \n"
    sudo systemctl restart nginx
}

configureWsgi(){
    """Configuring wsgi"""
    printf "******************Configuring wsgi************************\n"
    sudo bash -c 'cat <<EOF> ./wsgi_config.json
    {
        "uwsgi":{
            "server": ["0.0.0.0:5000"],
            "module": "Yummy-Recipes-Api:app",
            "master": true,
            "processes": 5,
        }
    }
    EOF'
}
startApp(){
    """Starting App"""
    printf "*******************Starting App*************************** \n"
    #python app.py
    #uwsgi --socket 0.0.0.0:5000 --protocol=http -w wsgi # add & at the end here to run in background
    uwsgi --json wsgi_config.json
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
    startApp
}

run

