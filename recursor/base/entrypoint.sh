#!/bin/bash

export DO_NOT_QUERY=${DO_NOT_QUERY:-""}
export FORWARD_ZONES=${FORWARD_ZONES:-"1.1.1.1,1.0.0.1"}
export PORT=${PORT:-"1153"}
export THREADS=${THREADS:-"4"}
export VERBOSITY=${VERBOSITY:-"1"}
export MSG_CACHE_SIZE=${MSG_CACHE_SIZE:-"256m"}
export RRSET_CACHE_SIZE=${RRSET_CACHE_SIZE:-"512m"}
export NEG_CACHE_SIZE=${NEG_CACHE_SIZE:-"128m"}
export KEY_CACHE_SIZE=${KEY_CACHE_SIZE:-"128m"}

IFS=','
NL=$'\n'

zones=""

for zone in $FORWARD_ZONES;
do 
  zones="${zones}${NL}  forward-addr: ${zone}";
done

donotquery=""

for donot in $DO_NOT_QUERY;
do 
  donotquery="${donotquery}${NL}  do-not-query-address: ${donot}";
done


localzones=""
# echo $LOCAL_ZONES;
IFS=";"
ZONEARR=($LOCAL_ZONES)
# echo "zonearr count: ${#ZONEARR[@]}"
# echo "zonearr count: $ZONEARR"
for LOCAL in ${ZONEARR[@]}; do 
  # echo "local: $LOCAL"
  IFS="|" 
  ZONEDATA=($LOCAL)
  # echo "zonedata0: ${ZONEDATA[0]}"
  # echo "zonedata1: ${ZONEDATA[1]}"
  localzone="${NL}  local-zone: \"${ZONEDATA[0]}\" typetransparent"
  IFS=","
  for data in ${ZONEDATA[1]};
  do
    # echo "data: $data"
    localzone="${localzone}${NL}    local-data: \"${data}\"";
  done
  localzones="${localzones}${localzone}"
done

cat <<EOF > /etc/unbound/unbound.conf
server:
  interface: 0.0.0.0
  interface: ::0
  port: ${PORT}
  num-threads: ${THREADS}
  verbosity: ${VERBOSITY}
  use-systemd: no
  do-daemonize: no
  use-syslog: no
  statistics-interval: 30
  outgoing-range: 4096
  num-queries-per-thread: 1024
  cache-max-ttl: 14400
  cache-min-ttl: 300
  hide-identity: yes
  hide-version: yes
  minimal-responses: yes${donotquery}
  access-control: 0.0.0.0/0 allow
  do-not-query-localhost: yes
  msg-cache-size: ${MSG_CACHE_SIZE}
  rrset-cache-size: ${RRSET_CACHE_SIZE}
  neg-cache-size: ${NEG_CACHE_SIZE}
  key-cache-size: ${KEY_CACHE_SIZE}${localzones}
forward-zone:
  name: "."${zones}
EOF

cat /etc/unbound/unbound.conf

unbound -c /etc/unbound/unbound.conf