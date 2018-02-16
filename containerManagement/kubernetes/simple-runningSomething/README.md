# Kubernetes test cluster

State: Working.

This variant is loosely based on [this tutorial](https://blog.alexellis.io/kubernetes-in-10-minutes/). It creates a kubernetes cluster running 1 master and 2 nodes. You can uncomment nodes in the Vagrantfile to get more nodes in the cluster.

Once you have it up, you can test with `curl localhost:2081/guid`.

## How

### To start

* Run `vagrant up` to get the virtual machines.

### Test

* `curl localhost:2081/guid`
* `vagrant ssh node1`
  * `kubectl get all --namespace=kube-system`
  * `kubectl get pods`
  * `kubectl get pods --output=yaml` - This one will loose sanity as you run more pods.
