# Use with Cloudflare Zero Trust

If you want to use the WARP client with Cloudflare Zero Trust, just start the container without specifying license key, use `docker exec -it warp bash` to get into the container and follow these steps:

1. `warp-cli registration delete` to delete current registration
2. `warp-cli teams-enroll <your-team-name>` to enroll the device
3. Open the link in the output in a browser and follow the instructions to complete the registration
4. On the success page, right-click and select **View Page Source**.
5. Find the HTML metadata tag that contains the token. For example, `<meta http-equiv="refresh" content"=0;url=com.cloudflare.warp://acmecorp.cloudflareaccess.com/auth?token=yeooilknmasdlfnlnsadfojDSFJndf_kjnasdf..." />`
6. Copy the URL field: `com.cloudflare.warp://<your-team-name>.cloudflareaccess.com/auth?token=<your-token>`
7. In the terminal, run the following command using the URL obtained in the previous step: `warp-cli registration token com.cloudflare.warp://<your-team-name>.cloudflareaccess.com/auth?token=<your-token>`. If you get an API error, then the token has expired. Generate a new one by refreshing the web page and quickly grab the new token from the page source.
8. `warp-cli connect` to reconnect using new registration.
9. Wait untill `warp-cli status` shows `Connected`.
10. Try `curl --socks5-hostname 127.0.0.1:1080 https://cloudflare.com/cdn-cgi/trace` to verify the connection.

This is only needed for the first time. After the device is enrolled, the registration information will be stored in the `./data` directory, if you don't delete them, the container will automatically use the registration information to connect to the WARP service after restart or recreate.
