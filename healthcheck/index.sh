#!/bin/bash

# exit when any command fails
set -e

# check if the proxy is working
PROXY_IP=$(curl -x socks5h://127.0.0.1:1080 https://cloudflare.com/cdn-cgi/trace | grep ip= | cut -d= -f2)
SERVER_IP=$(curl https://cloudflare.com/cdn-cgi/trace | grep ip= | cut -d= -f2)

if [ "$PROXY_IP" != "$SERVER_IP" ]; then
  echo "Health check passed!"
  exit 0
else
  echo "Health check failed!"
  exit 1
fi
