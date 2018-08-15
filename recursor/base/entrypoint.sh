#!/bin/sh

export DO_NOT_QUERY=${DO_NOT_QUERY:-""}
export FORWARD_ZONES=${FORWARD_ZONES:-"1.1.1.1,1.0.0.1"}
export PORT=${PORT:-"1153"}
export THREADS=${THREADS:-"4"}
export VERBOSITY=${VERBOSITY:-"1"}

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
  log-queries: yes
  log-replies: yes
forward-zone:
  name: "."${zones}

EOF

unbound -c /etc/unbound/unbound.conf