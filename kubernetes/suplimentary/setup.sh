#!/bin/bash
# Stuff to get a master/node set up.

function master1
{
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    apt-get install -y docker-ce wget

    cd /tmp
    wget https://storage.googleapis.com/kubernetes-release/release/v1.9.1/kubernetes-server-linux-amd64.tar.gz
    tar -xzf kubernetes-server-linux-amd64.tar.gz
}

function node
{
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    apt-get install -y docker-ce wget
    
    cd /tmp
    wget https://storage.googleapis.com/kubernetes-release/release/v1.9.1/kubernetes-client-linux-amd64.tar.gz
    wget https://storage.googleapis.com/kubernetes-release/release/v1.9.1/kubernetes-node-linux-amd64.tar.gz
}

case $1 in
    "master1")
        master1
    ;;
    
    "node")
        node
    ;;
esac

