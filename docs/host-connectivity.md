# Host connectivity issue

This issue often arises when using Zero Trust. You may find that you can run `curl --socks5-hostname 127.0.0.1:1080 https://cloudflare.com/cdn-cgi/trace` inside the container, but cannot run this command outside the container (from host or another container). This is because Cloudflare WARP client is grabbing the traffic. There are three solutions.

If you have permission to edit the [split tunnel settings](https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/configure-warp/route-traffic/split-tunnels/), you can add the subnet of your docker network to the split tunnel.

If you don't have the permission, use `docker exec warp-test warp-cli --accept-tos tunnel dump` to list your current excluded subnets, and carefully select one of them to set as the docker network subnet. The subnet you choose should be within the [private address range](https://en.wikipedia.org/wiki/Private_network#Private_IPv4_addresses); using a public address will prevent you from accessing certain services properly. This solution can be quite brittle and manual as you may need to change the subnet when your organization changes the excluded subnets, but it won't cause any other problems.

The third solution is to pass environment variable `BETA_FIX_HOST_CONNECTIVITY=1` to container, the container will add checks for host connectivity into [healthchecks](healthcheck.md) and automatically fix it if necessary. **This may prevent you from accessing certain intranet services of your organization**, as the docker network subnet may conflict with the addresses of these services. This is a beta feature and may not work in all cases. If you encounter any issues, please report them.
