#!/bin/bash
# docker compose
sudo curl -L https://github.com/docker/compose/releases/download/v2.17.2/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

rm "$HOME"/.docker/cli-plugins/docker-compose-BKP
ln -s /usr/local/bin/docker-compose "$HOME"/.docker/cli-plugins/docker-compose

docker info | grep -oP "(?<=Registry: ).*"