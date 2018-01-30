#!/bin/bash
# Stuff to get a master/node set up.

serverURL='https://storage.googleapis.com/kubernetes-release/release/v1.9.1/kubernetes-server-linux-amd64.tar.gz'
clientURL='https://storage.googleapis.com/kubernetes-release/release/v1.9.1/kubernetes-client-linux-amd64.tar.gz'
nodeURL='https://storage.googleapis.com/kubernetes-release/release/v1.9.1/kubernetes-node-linux-amd64.tar.gz'

function master1
{
    prep
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    apt-get install -y docker-ce wget

    get "$serverURL"
}

function node
{
    prep
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    apt-get install -y docker-ce wget
    
    #get "$clientURL"
    get "$nodeURL"
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
    
    if ! [ -e "$fileName" ]; then
        wget "$url"
    else
        echo "Skipping fetch of $fileName since it already exists."
    fi
    
    tar -xzf "$fileName"
}

function prep
{
    if [ "$workingDir" == '' ]; then
        export workingDir="/usr/setup/cache"
        mkdir -p "$workingDir"
        cd "$workingDir"
        echo "Prepped $workingDir."
    else
        echo "Already prepped $workingDir."
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
    
    "node") # Provision a worker node.
        node
    ;;
    "precache") # Warm the cache so that stuff doesn't have to be downloaded on each server.
        preCache
    ;;
    *)
        showHelp
    ;;
esac

