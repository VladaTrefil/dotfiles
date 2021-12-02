#!/bin/sh

port=3000

if [[ -n $1 ]]; then
  port=$1
fi

TASK=`lsof -wni tcp:"$port" | grep -o -E "ruby\s*\d{3,5}" | head -1 | grep -E -o "\d{3,5}"`

kill -9 $TASK
