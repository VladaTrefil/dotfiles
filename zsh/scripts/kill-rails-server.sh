#!/bin/sh

TASK=`lsof -wni tcp:3000 | grep -o -E "ruby\s*\d{3,5}" | head -1 | grep -E -o "\d{3,5}"`

kill -9 $TASK
