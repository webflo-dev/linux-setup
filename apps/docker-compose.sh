#!/bin/zsh

docker-compose_info() {
    echo "https://docs.docker.com/compose"
}

docker-compose_install() {
    curl -sSL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    docker-compose --version
}
