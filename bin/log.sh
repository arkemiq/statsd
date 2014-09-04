#!/bin/bash

PATH=$PATH:/usr/local/bin
root="/opt/statsd"
forever="/usr/local/bin/node node_modules/forever/bin/forever"

bin=`dirname "$0"`
cd "$bin"/..

$forever logs $1

exit 0
