# Enable MASQUE

[MASQUE](https://blog.cloudflare.com/zero-trust-warp-with-a-masque/) is WARP's new protocol which is more unlikely to be block by firewall (of your company or ISP) than WireGuard.

If you are using Zero Trust, go to Cloudflare Zero Trust portal and set [device tunnel protocol](https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/configure-warp/warp-settings/#device-tunnel-protocol) to MASQUE.

If you are using consumer account, you can enable MASQUE by following the steps below:

1. run `docker exec -it warp bash` to get into the container shell
2. run `warp-cli tunnel protocol set MASQUE` to enable MASQUE
3. run `warp-cli settings list` to check if MASQUE is enabled
