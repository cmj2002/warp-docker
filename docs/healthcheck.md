# Health check

The health check of the container will verify if the WARP client inside the container is working properly. If the check fails, the container will automatically restart. Specifically, 10 seconds after starting, a check will be performed every 15 seconds. If the inspection fails for 3 consecutive times, the container will be marked as unhealthy and trigger an automatic restart.

By default, the health check only checks if the WARP client is running. Sometime you may face a [host connectivity issue](host-connectivity.md), which is not covered by the default health check. If `BETA_FIX_HOST_CONNECTIVITY=1` is passed, host connectivity check will be added to the health check. If the check fails, the container will automatically fix it. This may prevent you from accessing certain intranet services of your organization, as the docker network subnet may conflict with the addresses of these services. This is a beta feature and may not work in all cases. If you encounter any issues, please report them.

If you don't want the container to restart automatically, you can remove `restart: always` from the `docker-compose.yml`. You can also modify the parameters of the health check through the `docker-compose.yml`.
