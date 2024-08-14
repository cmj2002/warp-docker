#!/bin/bash

curl -fsS "https://cloudflare.com/cdn-cgi/trace" | grep -qE "warp=(plus|on)" || exit 1
exit 0
