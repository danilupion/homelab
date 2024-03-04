# Homelab

A collection of k8s stacks to run a homelab.

## Installation

### Single Node K8S Cluster
On the server run the following file to install a single node k8s cluster. It has been tested on Ubuntu 22.04

```bash
install-k8s-cluster.sh
```

#### Versions
- k8s: 1.29.2-1.1

### Homelab

Once k8s credentials are available use them (.kube config file) run the following file to install the homelab.

```bash(from k8s cluster or remotely)
install-homelab.sh
```

#### Versions
- cilium: 1.14.7
- metallb: 0.14.3
- cert-manager: 1.14.3
- ingress-nginx: 4.10.0