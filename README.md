## Inception 42 project:
This repository contains my attempt at the Inception project from 42.
The main goal of this project is to learn how to use docker and create your own images
## Overview:
Sets up a WordPress page using nginx and mariadb<br/>
One container is used per service
## Requirements:
You must provide an `.env` file for the project to work.<br/>
You can place it in either:
- `/home/.env`
- The `srcs` directory of the project


For the project to work on your machine you will also need to have docker installed<br/>
(Here's how to install it assuming that you're using apt as your package manager)
```bash
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
```

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```


## How to use:

Creates the containers and launches everything
```bash
make up
```
Stops the containers but doesn't wipe data

```bash
make down
```

Stop the containers and wipes all data
```bash
make clean
```
