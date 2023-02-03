#/bin/bash

# install ssh
sudo apt install ssh -y
sudo systemctl enable ssh
sudo systemctl start ssh

# install ansible
sudo apt install ansible -y

