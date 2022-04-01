#!/bin/sh

port=3000

if [ -n $1 ]; then
  port=$1
fi

TASK=`lsof -wni tcp:3000 | grep -o -E "ruby\s*[[:digit:]]*" | head -1 | grep -E -o "[[:digit:]]*"`

kill -9 $TASK
