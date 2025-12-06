#!/bin/bash

# exit when any command fails
set -e

# List of Psiphon locations
LOCATIONS=("AT" "BE" "BG" "CA" "CH" "CZ" "DE" "DK" "EE" "ES" "FI" "FR" "GB" "HU" "IE" "IN" "IT" "JP" "LV" "NL" "NO" "PL" "RO" "RS" "SE" "SG" "SK" "US")

# Start a psiphon instance for each location
for i in "${!LOCATIONS[@]}"; do
  LOCATION=${LOCATIONS[$i]}
  PORT=$((1081 + i))
  HTTP_PORT=$((8081 + i))

  # Create a config file for each instance
  mkdir -p /home/psiphon/.config/psiphon
  cat > /home/psiphon/.config/psiphon/psiphon-$LOCATION.config <<EOL
{
  "EgressRegion": "$LOCATION",
  "ListenInterface": "127.0.0.1",
  "LocalSocksProxyPort": $PORT,
  "LocalHttpProxyPort": $HTTP_PORT
}
EOL

  # Start psiphon
  /usr/bin/psiphon-tunnel-core -config /home/psiphon/.config/psiphon/psiphon-$LOCATION.config &
done

# Create haproxy config
cat > /home/psiphon/haproxy.cfg <<EOL
global
  log 127.0.0.1 local0
  log 127.0.0.1 local1 notice

defaults
  log     global
  mode    tcp
  option  tcplog
  option  dontlognull
  timeout connect 5000
  timeout client  50000
  timeout server  50000

listen socks5
  bind :1080
  mode tcp
  balance roundrobin
EOL

for i in "${!LOCATIONS[@]}"; do
  PORT=$((1081 + i))
  echo "  server psiphon-$i 127.0.0.1:$PORT check" >> /home/psiphon/haproxy.cfg
done

# Start haproxy in the foreground
haproxy -f /home/psiphon/haproxy.cfg
