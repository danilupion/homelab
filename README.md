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

Once k8s credentials are available use them (.kube config file) make a copy of values-template.yaml and update the file with proper values.

```bash(from k8s cluster)
cp values-template.yaml values.yaml
```

And run the following file to install the homelab.

```bash(from k8s cluster or remotely)
install-homelab.sh
```

#### Versions
- [cilium](https://cilium.io/): 1.14.7
- [metallb](https://metallb.universe.tf/): 0.14.3
- [cert-manager](https://cert-manager.io/): 1.14.3
- [ingress-nginx](https://kubernetes.github.io/ingress-nginx/): 4.10.0

## Helm Charts

### metallb-config (single node ip pool)

### cert-manager-letsencrypt-cloudflare (Cluster issuer for Let's Encrypt with DNS-01 challenge using Cloudflare)