#!/bin/bash

PATH=$PATH:/usr/local/bin
root="/opt/statsd"
forever='node_modules/forever/bin/forever'

bin=`dirname "$0"`
cd "$bin"/..

"$forever" stop "bin/statsd_ts"

exit 0
