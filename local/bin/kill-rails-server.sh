#!/bin/sh

if [ $# -eq 0 ]; then
  port=3000
else
  port=$1
fi

if [ -n $port ]; then
  echo "Killing server on tcp port $port"

  TASK=`lsof -wni tcp:$port | grep -o -E "ruby\s*[[:digit:]]*" | head -1 | grep -E -o "[[:digit:]]*"`

  kill -9 $TASK
fi
