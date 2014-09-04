#!/bin/bash

PATH=$PATH:/usr/local/bin
root="/opt/statsd"
logpath='/mnt/log'
forever="node_modules/forever/bin/forever"

bin=`dirname "$0"`
cd "$bin"/..

if [ ! -f "$forever" ]; then
	echo "forever is not installed"
  npm install
fi

if [ ! -d "$logpath" ]; then
  mkdir -p "$logpath"
fi

"$forever" stop "bin/statsd_ts"
i=0
for f in config*.js
do
  "$forever" start -l "${logpath}/forever-$i.log" -o "${logpath}/out-$i.log" -e "${logpath}/err-$i.log" -a "bin/statsd_ts" "$f"
  let "i++"
done

exit 0
