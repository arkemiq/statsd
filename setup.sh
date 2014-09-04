#!/bin/bash

# environment variables:
# $PREFIX
# $RELAYS
# $REPEATERS
# $GRAPHITES

PATH=$PATH:/usr/local/bin
root="/opt/statsd"

if [ -n "$PREFIX" ]; then
  PREFIX=$PREFIX
else
  PREFIX="pi"
fi

if [ -n "$RELAYS" -o -n "$REPEATERS" ]; then
  if [ -n "$RELAYS" ]; then 
    SERVER_LIST=$(echo "$RELAYS" | tr , " ")
  elif [ -n "REPEATERS" ]; then
    SERVER_LIST=$(echo "$REPEATERS" | tr , " ")
  fi
  SI=( $SERVER_LIST )
  SERVERS=
  i=1
  total=${#SI[*]}
  OIFS=$IFS
  IFS=':'
  for s in "${SI[@]}"
  do
    IN=( $s )
    HOST=${IN[0]}
    PORT=${IN[1]}
    if [ -z $PORT ]; then PORT=8125; fi
    SERVERS+="{host: \"$HOST\", port: $PORT}"
    if [ $i != $total ]; then
      SERVERS+=","
      let "i++"
    fi
  done
  IFS=$OIFS
  if [ -n "$RELAYS" ]; then 
    sed -e "s/RELAY_SERVERS/$SERVERS/g" -e "s/PREFIX/$PREFIX/g" "${root}/_relay.js" > "${root}/config.js"
  elif [ -n "REPEATERS" ]; then
    sed -e "s/REPEATER_SERVERS/$SERVERS/g" -e "s/PREFIX/$PREFIX/g" "${root}/_repeater.js" > "${root}/config.js"
  fi
  echo "[config.js] file is generated"
elif [ -n "$GRAPHITES" ]; then
  SERVER_LIST=$(echo "$GRAPHITES" | tr , " ")
  SI=( $SERVER_LIST )
  i=1
  for s in "${SI[@]}"
  do
    let "UDP=8125-i"
    let "MGMT=8126+i"
    sed -e "s/GRAPHITE/$s/g" -e "s/PREFIX/$PREFIX/g" -e "s/8126/$MGMT/g"  -e "s/8125/$UDP/g" "${root}/_config.js" > "${root}/config${i}.js"
    echo "[config${i}.js] file is generated"
    let "i++"
  done
fi

# packages are already installed
pushd $root
npm install
popd $root

exit 0


