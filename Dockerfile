FROM ubuntu:22.04

ARG WARP_VERSION
ARG GOST_VERSION
ARG COMMIT_SHA
ARG TARGETPLATFORM

LABEL org.opencontainers.image.authors="cmj2002"
LABEL org.opencontainers.image.url="https://github.com/cmj2002/warp-docker"
LABEL WARP_VERSION=${WARP_VERSION}
LABEL GOST_VERSION=${GOST_VERSION}
LABEL COMMIT_SHA=${COMMIT_SHA}

COPY entrypoint.sh /entrypoint.sh
COPY ./healthcheck /healthcheck

# install dependencies
RUN case ${TARGETPLATFORM} in \
      "linux/amd64")   export ARCH="amd64" ;; \
      "linux/arm64")   export ARCH="armv8" ;; \
      *) echo "Unsupported TARGETPLATFORM: ${TARGETPLATFORM}" && exit 1 ;; \
    esac && \
    echo "Building for ${TARGETPLATFORM} with GOST ${GOST_VERSION}" &&\
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl gnupg lsb-release sudo jq ipcalc && \
    curl https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list && \
    apt-get update && \
    apt-get install -y cloudflare-warp && \
    apt-get clean && \
    apt-get autoremove -y && \
    MAJOR_VERSION=$(echo ${GOST_VERSION} | cut -d. -f1) && \
    MINOR_VERSION=$(echo ${GOST_VERSION} | cut -d. -f2) && \
    # detect if version >= 2.12.0, which uses new filename syntax
    if [ "${MAJOR_VERSION}" -ge 3 ] || [ "${MAJOR_VERSION}" -eq 2 -a "${MINOR_VERSION}" -ge 12 ]; then \
      NAME_SYNTAX="new" && \
      if [ "${TARGETPLATFORM}" = "linux/arm64" ]; then \
        ARCH="arm64"; \
      fi && \
      FILE_NAME="gost_${GOST_VERSION}_linux_${ARCH}.tar.gz"; \
    else \
      NAME_SYNTAX="legacy" && \
      FILE_NAME="gost-linux-${ARCH}-${GOST_VERSION}.gz"; \
    fi && \
    echo "File name: ${FILE_NAME}" && \
    curl -LO https://github.com/ginuerzh/gost/releases/download/v${GOST_VERSION}/${FILE_NAME} && \
    if [ "${NAME_SYNTAX}" = "new" ]; then \
      tar -xzf ${FILE_NAME} -C /usr/bin/ gost; \
    else \
      gunzip ${FILE_NAME} && \
      mv gost-linux-${ARCH}-${GOST_VERSION} /usr/bin/gost; \
    fi && \
    chmod +x /usr/bin/gost && \
    chmod +x /entrypoint.sh && \
    chmod +x /healthcheck/index.sh && \
    useradd -m -s /bin/bash warp && \
    echo "warp ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/warp

USER warp

# Accept Cloudflare WARP TOS
RUN mkdir -p /home/warp/.local/share/warp && \
    echo -n 'yes' > /home/warp/.local/share/warp/accepted-tos.txt

ENV GOST_ARGS="-L :1080"
ENV WARP_SLEEP=2
ENV REGISTER_WHEN_MDM_EXISTS=
ENV WARP_LICENSE_KEY=
ENV BETA_FIX_HOST_CONNECTIVITY=
ENV WARP_ENABLE_NAT=

HEALTHCHECK --interval=15s --timeout=5s --start-period=10s --retries=3 \
  CMD /healthcheck/index.sh

ENTRYPOINT ["/entrypoint.sh"]