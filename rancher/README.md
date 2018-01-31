# Rancher

This gives you an empty Rancher cluster with nodes attached that you can play with.

## Considerations

* Resource usage (In particular memory usage)
  * I've disabled nodes 4-6, to save 3GB of RAM. But if you want a larger cluster, simply uncomment them in the Vagrantfile. Similarly, if you want a really big cluster, that's the place to do it.

## TODOs

* Add a [second master node](http://rancher.com/docs/rancher/latest/en/installing-rancher/installing-server/#launching-rancher-server---full-activeactive-ha) to make it HA. 
