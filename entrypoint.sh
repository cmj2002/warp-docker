#!/bin/bash

# exit when any command fails
set -e

# check if /dev/net/tun is available
if [ ! -e /dev/net/tun ]; then
    if [ -n "$LEGACY_TUN_SUPPORT" ]; then
        echo "WARN: LEGACY_TUN_SUPPORT enabled, creating /dev/net/tun..."
        sudo mkdir -p /dev/net
        sudo mknod /dev/net/tun c 10 200
        sudo chmod 600 /dev/net/tun
    else
        echo "CRITIC: /dev/net/tun not pass, check https://github.com/cmj2002/warp-docker/blob/main/docs/tun-not-permitted.md for more information"
        exit 1
    fi
fi

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

# if /var/lib/cloudflare-warp/reg.json not exists, setup new warp client
if [ ! -f /var/lib/cloudflare-warp/reg.json ]; then
    # if /var/lib/cloudflare-warp/mdm.xml not exists or REGISTER_WHEN_MDM_EXISTS not empty, register the warp client
    if [ ! -f /var/lib/cloudflare-warp/mdm.xml ] || [ -n "$REGISTER_WHEN_MDM_EXISTS" ]; then
        warp-cli registration new && echo "Warp client registered!"
        # if a license key is provided, register the license
        if [ -n "$WARP_LICENSE_KEY" ]; then
            echo "License key found, registering license..."
            warp-cli registration license "$WARP_LICENSE_KEY" && echo "Warp license registered!"
        fi
    fi
    # connect to the warp server
    warp-cli --accept-tos connect
else
    echo "Warp client already registered, skip registration"
fi

# disable qlog if DEBUG_ENABLE_QLOG is empty
if [ -z "$DEBUG_ENABLE_QLOG" ]; then
    warp-cli debug qlog disable
else
    warp-cli debug qlog enable
fi

# start the proxy
gost $GOST_ARGS
