# Homelab

A collection of k8s stacks to run a homelab.

## Installation

### Homelab

Mke a copy of values-template.yaml and update the file with proper values.

*Note*: bash 4.0 or higher is required to run the following commands.

```bash(from k8s cluster)
cp values-template.yaml values.yaml
```

And run the following file to install the homelab.

```bash(from k8s cluster or remotely)
install-homelab.sh
```

#### Versions
- [cilium](https://cilium.io/): 1.17.3
- [metallb](https://metallb.universe.tf/): 0.14.9
- [cert-manager](https://cert-manager.io/): v1.17.1
- [ingress-nginx](https://kubernetes.github.io/ingress-nginx/): 4.12.1
- [sealed-secrets](https://sealed-secrets.netlify.app/): 2.17.2

## Update (configuration)

After you have made changes in the configuration (charts or values.yaml) you can run the following file to update the homelab.

```bash(from k8s cluster or remotely)
update-homelab.sh
```

## Services Configuration

Global settings:

* uid
* gid
* tz

Those settings can be overridden per service, for example:

``` 
prowlarr:
  uid: 1000
  gid: 1000
  tz: Europe/Madrid
```

## Helm Charts

### Networking

#### metallb-config (single node ip pool)

#### custom-dns (based on [CoreDNS](https://coredns.io/))

### Certificates

#### cert-manager-letsencrypt-cloudflare (Cluster issuer for Let's Encrypt with DNS-01 challenge using Cloudflare)

### Indexing

#### prowlarr (based on [Prowlarr](https://prowlarr.com))

Supports socks5 sidecar, creation of the secret is left to the user

```shell
kubectl create -n indexing secret generic prowlarr-socks5-sidecar-key --from-file=id_rsa=.ssh/id_socksuser
```

#### nzbhydra2 (based on [NZBHydra2](https://github.com/theotherp/nzbhydra2))

### Downloading

#### transmission (based on [Transmission](https://transmissionbt.com/))

#### sabnzbd (based on [SABnzbd](https://sabnzbd.org/))
You probably want to have a look at this https://sabnzbd.org/wiki/extra/hostname-check.html

### Media Management

#### radarr (based on [Radarr](https://radarr.video/))

#### sonarr (based on [Sonarr](https://sonarr.tv/))

#### bazarr (based on [Bazarr](https://www.bazarr.media/))

#### lidarr (based on [Lidarr](https://lidarr.audio/))

#### readarr (based on [Readarr](https://readarr.com/))

#### calibre (based on [Calibre](https://calibre-ebook.com/))

#### calibre-web (based on [Calibre-Web](https://github.com/janeczku/calibre-web))

### Media Requests

#### jellyseerr (based on [Jellyseerr](https://github.com/Fallenbagel/jellyseerr))

#### overseerr (based on [Overseerr](https://overseerr.dev/))

### Media Streaming

#### jellyfin (based on [Jellyfin](https://jellyfin.org/))
Once installed go to https://jellyfin.yourdomain/web/#/wizardstart.html to configure the server.

#### plex (based on [Plex Media Server](https://www.plex.tv/))
For native apps in the same network you will need to set Settings -> Network -> Custom server access URLs to something like `https://plex.yourdomain.tld`

#### emby (based on [Emby](https://emby.media/))

### Tools

#### [kubernetes-dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)

#### homarr (based on [Homarr](https://homarr.dev/))

#### filebrowser (based on [File Browser](https://filebrowser.org/)
This you can use as .filebrowser.json
```json
{
  "port": 8080,
  "baseURL": "",
  "address": "",
  "log": "stdout",
  "database": "/database.db",
  "root": "/srv"
}
```

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

#### flaresolverr (based on [FlareSolverr](https://github.com/FlareSolverr/FlareSolverr))
Tool to solve Cloudflare challenges.

#### flare-bypasser (based on [Flare Bypasser](https://github.com/yoori/flare-bypasser))
Tool to solve Cloudflare challenges.

### Dev

#### docker-registry (based on [registry](https://hub.docker.com/_/registry))

### Observability

#### [metrics-server](https://github.com/kubernetes-sigs/metrics-server)

#### [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
Includes Prometheus, Grafana, Alertmanager, and kube-state-metrics
