#!/bin/bash

# exit when any command fails
set -e

interfaces=$(ip --json address | jq -r '
    .[] | 
    select(.ifname != "lo") | 
    .ifname
    ')

# if CloudflareWARP not started, abort
if [[ ! "$interfaces" =~ "CloudflareWARP" ]]; then
    echo "[fix-host-connectivity] CloudflareWARP not started, skip."
    exit 0
fi

# get excluded networks
networks=$(ip --json address | jq -r '
  .[] | 
  select((.ifname != "lo") and (.ifname != "CloudflareWARP")) | 
  .addr_info[] | 
  select(.family == "inet") | 
  "\(.local)/\(.prefixlen)"' | 
  xargs -I {} sh -c '
    if echo {} | grep -q "/32$"; then 
      echo {};
    else 
      ipcalc -n {} | grep Network | awk "{print \$2}";
    fi
  ')

# if no networks found, abort
if [ -z "$networks" ]; then
    echo "[fix-host-connectivity] WARNING: No networks found, abort."
    exit 0
fi

# add excluded networks to nft table cloudflare-warp and routing table
for network in $networks; do
    sudo nft add rule inet cloudflare-warp input ip saddr $network accept
    sudo nft add rule inet cloudflare-warp output ip daddr $network accept
    # stop packet from using routing table created by CloudflareWARP
    sudo ip rule add to $network lookup main priority 10
done
