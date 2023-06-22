#!/bin/bash
  
if command -v docker $> /dev/null; then
        echo "Docker is installed"
        exit
fi

packages=(
  docker-ce
  docker-ce-cli
  containerd.io
  docker-compose
  docker-compose-plugin
)

daemon_path='/etc/docker/daemon.json'

sudo apt-get update
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

for package in "${packages[@]}"; do
   sudo apt install -y "$package"
done

sudo groupadd docker

sudo usermod -aG docker ${USER}

sudo touch $daemon_path
sudo tee $daemon_path << EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "50m",
    "max-file": "3"
  }
}
EOF

sudo chown root:root "$daemon_path"
sudo systemctl restart docker


sudo su - omgili << EOF 
    
    sudo apt remove -y golang-docker-credential-helpers
    docker login --username webzio --password "yourpassword"
    for package in "${packages[@]}"; do
       sudo apt install -y "$package"
    done
     
EOF

