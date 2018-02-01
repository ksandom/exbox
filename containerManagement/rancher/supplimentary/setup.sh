#!/bin/bash
# Stuff to get a master/node set up.

function master1
{
    prep
    installDocker

    docker run -d --restart=unless-stopped -p 8080:8080 rancher/server:stable
    
    # Wait for the master to come up.
    while ! curl localhost:8080; do
        echo "Waiting for rancher to come up"
        sleep 3
    done
    
    # Wait for the registration tokens to be created.
    while ! curl localhost:8080/v1/registrationTokens | grep 'docker run'; do
        echo "The port is open, but the tokens have not yet been created. Please browse to http://localhost:8080 and follow the instructions to \"Add a newhost\" (top right). When asked for the host, set it to \"http://192.168.30.10:8080\" At that point, this should leap back into action. When I find a way to automate this, I will."
        sleep 3
    done
    
    
    # Find out what the command is to get a node to join, and save that for others to use.
    curl localhost:8080/v1/registrationTokens | sed 's/^.*"command":"sudo //g' | cut -d\" -f1 | sed 's/\\//g' > /vagrant/registrationCommand.secret
}

function node
{
    prep
    installDocker
    
    # Join the cluser.
    bash -c "`cat /vagrant/registrationCommand.secret`"
}

function client
{
    prep
    installDocker

    
}

function installDocker
{
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    apt-get install -y docker-ce wget
}

function preCache
{
    prep "supplimentary/cache"
    get "$serverURL"
    get "$nodeURL"
    get "$clientURL"
}

function get
{
    url="$1"
    fileName=`basename "$url"`
    
    startDir=`pwd`
    cd "$downloadDir"
    if ! [ -e "$fileName" ]; then
        wget "$url"
    else
        echo "Skipping fetch of $fileName since it already exists."
    fi
    cd "$startDir"
}

function unpack
{
    url="$1"
    fileName=`basename "$url"`
    
    tar -xzf "$downloadDir/$fileName"
}

function prep
{
    if [ "$workingDir" == '' ]; then
        export workingDir="${1:-/tmp/setup}"
        mkdir -p "$workingDir"
        cd "$workingDir"
        echo "Prepped $workingDir."
    else
        echo "Already prepped $workingDir."
    fi
    
    if [ -e /vagrant ]; then
        downloadDir="/vagrant/supplimentary/cache"
    else
        downloadDir="$workingDir"
    fi
}

function showHelp
{
    grep '["]) #' $0 | cut -d\" -f 2- | sed 's/["]) # /	/g' | column -ts \	
}


case $1 in
    "master1") # Provision the first master node.
        master1
    ;;
    
    "master2") # Provision the second master node.
        master2
    ;;
    
    "node") # Provision a worker node.
        node
    ;;
    "client") # Provision a client.
        client
    ;;
    "precache") # Warm the cache so that stuff doesn't have to be downloaded on each server.
        preCache
    ;;
    *)
        showHelp
    ;;
esac

