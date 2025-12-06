# Psiphon Docker

[![Docker Pulls](https://img.shields.io/docker/pulls/caomingjun/warp)](https://hub.docker.com/r/caomingjun/warp)
![PSYPHON version in latest image](https://img.shields.io/endpoint?url=https%3A%2F%2Fapi.caomingjun.com%2Fdockerhub-label%3Frepo%3Dcaomingjun%2Fwarp%26label%3DPSYPHON_VERSION%26display%3DPSYPHON%2520in%2520image)

Run official [Psiphon](https://psiphon.ca/) client in Docker.

## Usage

### Start the container

To run the Psiphon client in Docker, just write the following content to `docker-compose.yml` and run `docker-compose up -d`.

```yaml
version: "3"

services:
  psiphon:
    image: ghcr.io/your-username/psiphon-docker:latest
    container_name: psiphon
    restart: always
    ports:
      - "1080:1080"
```

Try it out to see if it works:

```bash
curl --socks5-hostname 127.0.0.1:1080 https://cloudflare.com/cdn-cgi/trace
```

The output should show a different IP address each time you run the command, as the load balancer cycles through the different Psiphon locations.

### Load Balancing

This Docker image runs multiple instances of the Psiphon client, each with a different location. A load balancer is used to distribute traffic across all the instances, providing a single SOCKS5 proxy on port 1080. This means that with each request, you'll be assigned a different IP address from a different location, enhancing your privacy and security.

## Build

You can use Github Actions to build the image yourself.

1. Fork this repository.
2. Create necessary variables and secrets in the repository settings:
   1. variable `REGISTRY`: for example, `ghcr.io`
   2. variable `IMAGE_NAME`: for example, `your-username/psiphon-docker`
   3. variable `DOCKER_USERNAME`: for example, `your-username`
   4. secret `DOCKER_PASSWORD`: generate a token in GitHub and fill in the token
3. Manually trigger the workflow `Build and push image` in the Actions tab.

This will build the image with the latest version of Psiphon client and push it to the specified registry.
