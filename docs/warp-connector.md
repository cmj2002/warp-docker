# Setting up as WARP connector

If you want to setup [WARP Connector](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/private-net/warp-connector)

> [!NOTE]
> If you have already started the container, stop it and delete the data directory.

1. Create `mdm.xml` as explained in Cloudflare WARP Connector [step 4](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/private-net/warp-connector/#4-install-a-warp-connector)
2. Mount the `mdm.xml` to path `/var/lib/cloudflare-warp/mdm.xml`
3. Start the container

Sample Docker Compose File:

```yaml
services:
  warp:
    image: caomingjun/warp
    container_name: warp
    restart: always
    ports:
      - "1080:1080"
    environment:
      - WARP_SLEEP=2
    cap_add:
      - NET_ADMIN
    sysctls:
      - net.ipv6.conf.all.disable_ipv6=0
      - net.ipv4.conf.all.src_valid_mark=1
      - net.ipv4.ip_forward=1
    volumes:
      - ./data:/var/lib/cloudflare-warp
      - ./config/warp/mdm.xml:/var/lib/cloudflare-warp/mdm.xml
```
