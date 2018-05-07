#!/bin/bash

#update Os
echo Updating OS
sudo apt-get update

#export lan variables
echo exporting LANG variables
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

#install python and dependancies
echo installing python 3.6 and dependancies
sudo apt-get install -y python=3.6
sudo apt-get install -y python-pip nginx 

#install virtualenv
sudo apt-get install -y virtualenv

#create Virtualenv
virtualenv -p /usr/bin/python3 demoenv

#clone git repo
git clone https://github.com/anyric/Yummy-Recipes-Api.git

#activate virtualenv
source demoenv/bin/activate

#enter project folder and install requirements
cd Yummy-Recipes-Api
sudo pip install -r requirements.txt

#configure host ip
echo configuring host ip
sudo rm -rf app.py
sudo bash -c 'cat <<EOF> ./app.py
"""module to run app"""
from apps import app

if __name__ == "__main__":
    app.run(host="0.0.0.0", threaded=True)
EOF'

#start nginx
echo starting nginx
sudo systemctl start nginx

#remove default config file
sudo rm -rf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

#nginx configuration
echo configuring ngix
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

#restart nginx
echo restating nginx
sudo systemctl restart nginx

#start app
echo stating app
export FLASK_APP=app.py
flask run

