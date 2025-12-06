ARG BASE_IMAGE=debian:bookworm-slim

FROM ${BASE_IMAGE}

ARG PSYPHON_VERSION
ARG COMMIT_SHA
ARG TARGETPLATFORM

LABEL org.opencontainers.image.authors="cmj2002"
LABEL org.opencontainers.image.url="https://github.com/cmj2002/warp-docker"
LABEL PSYPHON_VERSION=${PSYPHON_VERSION}
LABEL COMMIT_SHA=${COMMIT_SHA}

COPY entrypoint.sh /entrypoint.sh
COPY ./healthcheck /healthcheck

# install dependencies
RUN case ${TARGETPLATFORM} in \
      "linux/amd64")   export ARCH="amd64" ;; \
      "linux/arm64")   export ARCH="armv8" ;; \
      *) echo "Unsupported TARGETPLATFORM: ${TARGETPLATFORM}" && exit 1 ;; \
    esac && \
    echo "Building for ${TARGETPLATFORM}" &&\
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl gnupg lsb-release sudo jq ipcalc haproxy && \
    apt-get clean && \
    apt-get autoremove -y && \
    # download and install psiphon
    case ${TARGETPLATFORM} in \
      "linux/amd64")   curl -LO https://raw.githubusercontent.com/Psiphon-Labs/psiphon-tunnel-core-binaries/master/linux/psiphon-tunnel-core-x86_64 && mv psiphon-tunnel-core-x86_64 /usr/bin/psiphon-tunnel-core ;; \
      "linux/arm64")   curl -LO https://raw.githubusercontent.com/Psiphon-Labs/psiphon-tunnel-core-binaries/master/linux/psiphon-tunnel-core-arm64 && mv psiphon-tunnel-core-arm64 /usr/bin/psiphon-tunnel-core ;; \
    esac && \
    chmod +x /usr/bin/psiphon-tunnel-core && \
    chmod +x /entrypoint.sh && \
    chmod +x /healthcheck/index.sh && \
    useradd -m -s /bin/bash psiphon && \
    echo "psiphon ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/psiphon

USER psiphon

HEALTHCHECK --interval=15s --timeout=5s --start-period=10s --retries=3 \
  CMD /healthcheck/index.sh

ENTRYPOINT ["/entrypoint.sh"]
