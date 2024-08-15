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
  if ! sudo nft list table inet cloudflare-warp | grep -q "saddr $network accept"; then
    echo "[fix-host-connectivity] Adding $network to input chain of nft table cloudflare-warp ."
    sudo nft add rule inet cloudflare-warp input ip saddr $network accept
  fi
  if ! sudo nft list table inet cloudflare-warp | grep -q "daddr $network accept"; then
    echo "[fix-host-connectivity] Adding $network to output chain of nft table cloudflare-warp ."
    sudo nft add rule inet cloudflare-warp output ip daddr $network accept
  fi
  if ! ip rule list | grep -q "$network lookup main"; then
    # stop packet from using routing table created by CloudflareWARP
    echo "[fix-host-connectivity] Adding routing rule for $network."
    sudo ip rule add to $network lookup main priority 10
  fi
done
