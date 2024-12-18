# Use the proxy mode of WARP

> [!NOTE]
> This article is based on the current WARP documentation, and the WARP commands may be changed by Cloudflare in the future. If you encounter any issues during following the instructions, please open an issue.

> [!WARNING]
> UDP support is not available in the proxy mode of WARP.

Use `docker exec -it warp bash` to get into the container and run the following commands:

```bash
warp-cli mode proxy
warp-cli proxy port 40000
```

Create a new healthcheck script `new-healthcheck.sh` with content:

```bash
#!/bin/bash

curl -fsS --socks5-hostname 127.0.0.1:1080 "https://cloudflare.com/cdn-cgi/trace" | grep -qE "warp=(plus|on)" || exit 1
exit 0
```

Update the `docker-compose.yml` file:
1. set env `GOST_ARGS` to `-L :1080 -F=127.0.0.1:40000`
2. mount new healthcheck to `/healthcheck/connected-to-warp.sh`:

For example, the default `docker-compose.yml` file will be changed to:

```yaml
version: "3"

services:
  warp:
    image: caomingjun/warp
    container_name: warp
    restart: always
    ports:
      - "1080:1080"
    environment:
      - WARP_SLEEP=2
      - GOST_ARGS=-L :1080 -F=127.0.0.1:40000
      # - WARP_LICENSE_KEY= # optional
    cap_add:
      # Docker already have them, these are for podman users
      - MKNOD
      - AUDIT_WRITE
      # additional required cap for warp, both for podman and docker
      - NET_ADMIN
    sysctls:
      - net.ipv6.conf.all.disable_ipv6=0
      - net.ipv4.conf.all.src_valid_mark=1
    volumes:
      - ./data:/var/lib/cloudflare-warp
      - ./new-healthcheck.sh:/healthcheck/connected-to-warp.sh
```

After updating the `docker-compose.yml` file, run `docker-compose down && docker-compose up -d` to restart the container.
