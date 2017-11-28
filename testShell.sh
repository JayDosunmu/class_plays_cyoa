#!/bin/bash

event=1

temp=`cat Choice$event.txt | awk -F: ' NR == 3 { print $3 }'`

event=`expr $event + $temp`

echo "temp=$temp & event=$event"
