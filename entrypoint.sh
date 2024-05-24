#!/bin/bash

# exit when any command fails
set -e

# create a tun device
sudo mkdir -p /dev/net
sudo mknod /dev/net/tun c 10 200
sudo chmod 600 /dev/net/tun

# start dbus
sudo mkdir -p /run/dbus
if [ -f /run/dbus/pid ]; then
  sudo rm /run/dbus/pid
fi
sudo dbus-daemon --config-file=/usr/share/dbus-1/system.conf

# start the daemon
sudo warp-svc --accept-tos &

# sleep to wait for the daemon to start, default 2 seconds
sleep "$WARP_SLEEP"

# if /var/lib/cloudflare-warp/reg.json not exists, register the warp client
if [ ! -f /var/lib/cloudflare-warp/reg.json ]; then
    warp-cli registration new && echo "Warp client registered!"
    # if a license key is provided, register the license
    if [ -n "$WARP_LICENSE_KEY" ]; then
        echo "License key found, registering license..."
        warp-cli registration license "$WARP_LICENSE_KEY" && echo "Warp license registered!"
    fi
    # connect to the warp server
    warp-cli connect
else
    echo "Warp client already registered, skip registration"
fi

# start the proxy
gost $GOST_ARGS
