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

### Networking

#### metallb-config (single node ip pool)

#### custom-dns (based on [CoreDNS](https://coredns.io/))

### Certificates

#### cert-manager-letsencrypt-cloudflare (Cluster issuer for Let's Encrypt with DNS-01 challenge using Cloudflare)

### Security

#### wireguard (based on [WireGuard](https://www.wireguard.com/))

### Media Management

#### prowlarr (based on [Prowlarr](https://prowlarr.com))

#### transmission (based on [Transmission](https://transmissionbt.com/))

#### radarr (based on [Radarr](https://radarr.video/))

#### sonarr (based on [Sonarr](https://sonarr.tv/))

#### bazarr (based on [Bazarr](https://www.bazarr.media/))

#### lidarr (based on [Lidarr](https://lidarr.audio/))

#### jellyfin (based on [Jellyfin](https://jellyfin.org/))

#### plex (based on [Plex Media Server](https://www.plex.tv/))
For native apps in the same network you will need to set Settings -> Network -> Custom server access URLs to soemthing lik `https://plex.yourdomain`

#### jellyseerr (based on [Jellyseerr](https://github.com/Fallenbagel/jellyseerr))

#### homarr (based on [Homarr](https://homarr.dev/))

#### fileflows (based on [FileFlows](https://fileflows.com/))