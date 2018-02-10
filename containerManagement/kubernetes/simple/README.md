# Kubernetes test cluster

State: Working.

This variant is based on [this tutorial](https://blog.alexellis.io/kubernetes-in-10-minutes/). It creates a vanilla kubernetes clusters running a master/node and a node. You can uncomment nodes in the Vagrantfile to get more nodes in the cluster.

## How

### To start

* Run `vagrant up` to get the virtual machines.

### Test

* vagrant ssh node1
* `kubectl get all --namespace=kube-system`
