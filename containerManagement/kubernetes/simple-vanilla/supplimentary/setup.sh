#!/bin/bash
# Stuff to get a master/node set up.

serverURL='https://storage.googleapis.com/kubernetes-release/release/v1.9.1/kubernetes-server-linux-amd64.tar.gz'
clientURL='https://storage.googleapis.com/kubernetes-release/release/v1.9.1/kubernetes-client-linux-amd64.tar.gz'
nodeURL='https://storage.googleapis.com/kubernetes-release/release/v1.9.1/kubernetes-node-linux-amd64.tar.gz'

function master1
{
    prep
    installIncludedDocker
    prepAptForKubernetes
    
    installKubernetesViaApt
    
    initMaster
    
    harvestInformation
    
    # NOTE This will be removed in more complete setups.
    allowMasterToParticipate
}

function node
{
    prep
    installIncludedDocker
    prepAptForKubernetes
    
    installKubernetesViaApt
    
    setupKubeAdmUser
}

function client
{
    prep
    installIncludedDocker
    prepAptForKubernetes

    get "$clientURL"
    unpack "$clientURL"
}

function installLatestDocker
{
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    apt-get install -y docker-ce wget
}

function installIncludedDocker
{
    apt-get update
    apt-get install -qy docker.io wget
}

function prepAptForKubernetes
{
    apt-get update
    apt-get install -y apt-transport-https
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    
    echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
    apt-get update
}

function installKubernetesViaApt
{
    apt-get install -y kubelet kubeadm kubernetes-cni
}

function setupKubeAdmUser
{
    destinationUser='vagrant'
    destinationGroup="$destinationUser"
    sourceConfig='/vagrant/kubeConfig.secret'
    mkdir -p /home/$destinationUser/.kube
    sudo cp -f "$sourceConfig" /home/$destinationUser/.kube/config
    sudo chown -R "$destinationUser:$destinationGroup" /home/$destinationUser/.kube
    
    # TODO There is probably a better way, like running the kubectl commands as the user instead of as root. For now I'll work around this by setting up the root user additionally.
    
    mkdir -p /root/.kube
    sudo cp -f "$sourceConfig" /root/.kube/config
}

function initMaster
{
    # TODO Check version.
    myIP=`getMyIP`
    echo "$myIP" > /vagrant/masterIP.secret
    kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$myIP --kubernetes-version stable-1.8 --ignore-preflight-errors=all --skip-preflight-checks | tee  /tmp/startup.log
    
    generateKubeConfig
    setupKubeAdmUser
    
    # Flannel
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/k8s-manifests/kube-flannel-rbac.yml
}

function generateKubeConfig
{
    myIP=`getMyIP`
    echo "Using IP: $myIP"
    sed "s#https://10.0.2.15:6443#https://$myIP:6443#g" /etc/kubernetes/admin.conf > /vagrant/kubeConfig.secret
}

function harvestInformation
{
    grep 'kubeadm join' /tmp/startup.log > /vagrant/join.secret
}

function allowMasterToParticipate
{
    kubectl taint nodes --all node-role.kubernetes.io/master-
}

function initNode
{
    bash -c "`cat /vagrant/join.secret`"
}


function preCache
{
    prep "supplimentary/cache"
    get "$serverURL"
    get "$nodeURL"
    get "$clientURL"
}

function getMyIP
{
    expectedNetwork='192.168.50'
    myIP=`ip address | grep "inet.*$expectedNetwork" | awk '{print $2}' | cut -d\/ -f1`
    echo $myIP
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
    
    if [ -e /vagrant/supplimentary/cache ]; then
        export downloadDir="/vagrant/supplimentary/cache"
    else
        export downloadDir="$workingDir"
    fi
    
    swapoff -a
    sed -i 's/^.*swap$//g' /etc/fstab # Blanks the swap line. Not quite right, but good enough for now.
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
    "client") # Provision a client.
        client
    ;;
    "precache") # Warm the cache so that stuff doesn't have to be downloaded on each server.
        preCache
    ;;
    "ip") # Debug: Get the IP of the current machine.
        getMyIP
    ;;
    "home") # Debug: Configure home dir config.
        setupKubeAdmUser
    ;;
    "config") # Debug: Generate kube config.
        generateKubeConfig
    ;;
    *)
        showHelp
    ;;
esac

