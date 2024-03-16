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

## Update (configuration)

After you have made changes in the configuration (charts or values.yaml) you can run the following file to update the homelab.

```bash(from k8s cluster or remotely)
update-homelab.sh
```

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

#### nzbhydra2 (based on [NZBHydra2](https://github.com/theotherp/nzbhydra2))

#### transmission (based on [Transmission](https://transmissionbt.com/))

#### sabnzbd (based on [SABnzbd](https://sabnzbd.org/))
You probably want to have a look at this https://sabnzbd.org/wiki/extra/hostname-check.html

#### radarr (based on [Radarr](https://radarr.video/))

#### sonarr (based on [Sonarr](https://sonarr.tv/))

#### bazarr (based on [Bazarr](https://www.bazarr.media/))

#### lidarr (based on [Lidarr](https://lidarr.audio/))

#### readarr (based on [Readarr](https://readarr.com/))

#### jellyfin (based on [Jellyfin](https://jellyfin.org/))

#### plex (based on [Plex Media Server](https://www.plex.tv/))
For native apps in the same network you will need to set Settings -> Network -> Custom server access URLs to soemthing lik `https://plex.yourdomain`

#### emby (based on [Emby](https://emby.media/))

#### jellyseerr (based on [Jellyseerr](https://github.com/Fallenbagel/jellyseerr))

#### overseerr (based on [Overseerr](https://overseerr.dev/))

#### homarr (based on [Homarr](https://homarr.dev/))

#### fileflows (based on [FileFlows](https://fileflows.com/))

#### home-assistant (based on [Home Assistant](https://www.home-assistant.io/))

The following will be needed in the configuration.yaml file for Home Assistant to work with the ingress-nginx ([more info](https://www.home-assistant.io/integrations/http#reverse-proxies)):
```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 10.0.0.0/8 # Cilium's default CIDR
```

Probably you also want to install hacs (Home Assistant Community Store) to get more integrations and plugins.
https://hacs.xyz/