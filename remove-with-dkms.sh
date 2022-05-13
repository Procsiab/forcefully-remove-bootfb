#!/bin/bash -e
set -e

range=$(grep BOOTFB /proc/iomem | awk '{ print $1 }')
IFS='-' read -ra ADDR <<< "$range"

start=${ADDR[0]}
end=${ADDR[1]}

sleep 2

modprobe force-remove-bootfb bootfb_start=0x${start} bootfb_end=0x${end}
rmmod force-remove-bootfb
