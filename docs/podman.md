# Podman

[Podman](https://podman.io/) have [more strict security settings than Docker](https://blog.caomingjun.com/linux-capabilities-in-docker-and-podman/en/), so you need to add more capabilities to the container to make it work properly. If your podman is not a rootless installation, you can use the default `docker-compose.yml` file, as the additional capabilities required by the container are already included in the default configuration.

[Rootless Podman have more limitations](https://github.com/containers/podman/issues/7866). You can try to mount `/dev/tun` to avoid permission issues. Here is an example command to run the container with Podman:

```bash
podman run -d \
  --name warp \
  --restart always \
  -p 1080:1080 \
  -e WARP_SLEEP=2 \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  --sysctl net.ipv6.conf.all.disable_ipv6=0 \
  --sysctl net.ipv4.conf.all.src_valid_mark=1 \
  -v ./data:/var/lib/cloudflare-warp \
  docker.io/caomingjun/warp:latest
```

> [!NOTE]
> I am not a Podman user, the example command is [written by @tony-sung](https://github.com/cmj2002/warp-docker/issues/30#issuecomment-2371448959).
