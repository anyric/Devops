#!/bin/bash
#update Os
sudo apt-get update
#export lan variables
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
#install python and dependancies
sudo apt install python=3.6
sudo apt install python-pip

#install virtualenv
sudo apt install virtualenv

#create Virtualenv
virtualenv -p /usr/bin/python3 demoenv

#clone git repo
git clone https://github.com/anyric/Yummy-Recipes-Api.git

#activate virtualenv
source ./demoenv/bin/activate

cd Yummy-Recipes-Api
sudo pip install -r requirements.txt


