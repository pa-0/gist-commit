#!/bin/sh

domain=REDACTED
json="Content-Type: application/json"

unifi="https://unifi.$domain/api"
unifi_resolve="unifi.$domain:443:10.0.0.2"
unifi_user=REDACTED
unifi_pass=REDACTED

cloudflare="https://api.cloudflare.com/client/v4/zones/REDACTED/dns_records"
cf_token="Authorization: Bearer REDACTED"

# Get current DNS record from cloudflare (prone to failure so run first)
record=$(curl -X GET -H "$json" -H "$cf_token" -s $cloudflare | jq ".result[] | select(.name==\"$domain\")" 2>/dev/null)

if [ $? -ne 0 ]; then
  echo "[Update IP] Failed to get current record from Cloudflare."
  exit 1
fi

# Login to unifi controller and capture cookie
cookie=$(curl -X POST -H "$json" --resolve $unifi_resolve -d "{\"username\":\"$unifi_user\",\"password\":\"$unifi_pass\"}" -ks -o /dev/null -c - $unifi/login)

# Check if cookie was set by stripping out comments and blank lines
if [ -z "$(echo "$cookie" | sed -E '/^(#|$)/d')" ]; then
  echo "[Update IP] Unifi login failed."
  exit 1
fi

# Get WAN address of USG
ip=$(echo "$cookie" | curl -X GET -H "$json" --resolve $unifi_resolve -b - -ks $unifi/s/default/stat/device | jq -r '.data[] | select(.model=="UGW3") | .wan1.ip')
if [ -z "$ip" ]; then
  echo "[Update IP] Failed to get external IP."
  exit 1
fi

# Make sure we didn't get an erroneous address
if [ "$ip" = "0.0.0.0" ] || [ "${ip:0:3}" = "10." ] || ([ "${ip:0:4}" = "172." ] && [ "${ip:6:1}" = "." ] && [ ${ip:4:2} -ge 16 ] && [ ${ip:4:2} -lt 32 ]) || [ "${ip:0:8}" = "192.168." ]; then
  echo "[Update IP] WAN IP in private range: $ip"
  exit 1
fi

# Update A record if IP has changed
if [ -n "$record" ] && [ "$(echo $record | jq -r 'select(.type=="A").content')" != "$ip" ]; then
  echo "[Update IP] IPv4 is now $ip"
  curl -X PATCH -H "$json" -H "$cf_token" -d "{\"content\":\"$ip\"}" -s "$cloudflare/$(echo $record | jq -r 'select(.type=="A").id')"
fi

# Get our IPv6 address
ipv6=$(ip -6 addr show dev enp2s0 | sed -nr 's|\s+inet6 ([0-9a-f:]+)/[0-9]{2} scope global.+|\1|p')
if [ -z "$ipv6" ]; then
  # Attempt to fix IPv6 by restarting networking 
  systemctl restart systemd-networkd
  ipv6=$(ip -6 addr show dev enp2s0 | sed -nr 's|\s+inet6 ([0-9a-f:]+)/[0-9]{2} scope global.+|\1|p')

  if [ -z "$ipv6" ]; then
    echo "[Update IP] Failed to get IPv6."
    exit 1
  fi
fi

# Get our IPv6 address according to USG (for external access)
usg_ipv6=$(echo "$cookie" | curl -X GET -H "$json" --resolve $unifi_resolve -b - -ks $unifi/s/default/rest/firewallgroup | jq -r '.data[] | select(.name=="Server IPv6")')

# Update USG if changed
if [ -n "$usg_ipv6" ] && [ "$(echo "$usg_ipv6" | jq -r '.group_members[]')" != "$ipv6" ]; then
  echo "$cookie" | curl -X PUT -H "$json" --resolve $unifi_resolve -b - -d "{\"group_members\":[\"$ipv6\"]}" -ks $unifi/s/default/rest/firewallgroup/$(echo $usg_ipv6 | jq -r '._id')
fi

# Logout unifi
echo "$cookie" | curl -X POST --resolve $unifi_resolve -b - -ks -o /dev/null $unifi/logout

# Update AAAA record if IP has changed
if [ -n "$record" ] && [ "$(echo $record | jq -r 'select(.type=="AAAA").content')" != "$ipv6" ]; then
  echo "[Update IP] IPv6 is now $ipv6"
  curl -X PATCH -H "$json" -H "$cf_token" -d "{\"content\":\"$ipv6\"}" -s "$cloudflare/$(echo $record | jq -r 'select(.type=="AAAA").id')"
fi

dockerdir=/srv/docker
composefile=$dockerdir/docker-compose.yml
prefix=$(echo $ipv6 | sed -r 's/(.+)(:[0-9a-f]{1,4}){4}/\1/')

# Update haproxy with new IPv6 subnet
if [ "$(sed -nr 's|.+ (([0-9a-f:]{1,4}:){4}:)/64 .+|\1|p' $dockerdir/haproxy/haproxy.cfg)" != "$prefix::" ]; then
  sed -i -r 's|([0-9a-f:]{1,4}:){4}:/64|'$prefix'::/64|g' $dockerdir/haproxy/haproxy.cfg
  docker compose -f $composefile kill -s USR2 haproxy >/dev/null 2>&1

  # Do the same for secondary DNS server
  echo "
    sed -i -r 's|([0-9a-f:]{1,4}:){4}:/64|$prefix::/64|g' $dockerdir/haproxy/haproxy.cfg
    docker compose -f $composefile kill -s USR2 haproxy >/dev/null 2>&1
  " | ssh root@10.0.0.3 bash
fi