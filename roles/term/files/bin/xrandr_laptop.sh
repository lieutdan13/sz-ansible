#!/usr/bin/env bash

# TODO: pipe all greps to true and compare to an empty string
#set -euo pipefail

EXTERNAL_OUT=""

xrandr_out=`xrandr`

PRIMARY=`echo "$xrandr_out" | grep 'primary' | awk '{ print $1 }'`
PRIMARY_RESOLUTION="1920x1080"
echo "Laptop Display = $PRIMARY"
echo "${PRIMARY} Resolution = $PRIMARY_RESOLUTION"
echo

RIGHT_OF=$PRIMARY
EXTERNALS=`echo "$xrandr_out" | grep -v 'primary' | grep 'connected' | awk '{ print $1 }'`
for EXTERNAL_DEVICE in $EXTERNALS; do
    echo "External Display: $EXTERNAL_DEVICE"
    echo "$xrandr_out" | grep -E "^$EXTERNAL_DEVICE connected" > /dev/null
    EXTERNAL_CONNECTED=$?

    if [ $EXTERNAL_CONNECTED -eq 0 ]; then
        echo "${EXTERNAL_DEVICE} Connected: yes"
        echo "${EXTERNAL_DEVICE} Resolution: auto"
        echo "${EXTERNAL_DEVICE} Position: right of $RIGHT_OF"
        EXTERNAL_OUT="${EXTERNAL_OUT} --output $EXTERNAL_DEVICE --auto --right-of $RIGHT_OF"
        RIGHT_OF=$EXTERNAL_DEVICE
    else
        echo "${EXTERNAL_DEVICE} Connected: no"
        EXTERNAL_OUT="${EXTERNAL_OUT} --output $EXTERNAL_DEVICE --off"
    fi
    echo
done

echo
echo "xrandr --output $PRIMARY --mode $PRIMARY_RESOLUTION $EXTERNAL_OUT &"
xrandr --output $PRIMARY --mode $PRIMARY_RESOLUTION $EXTERNAL_OUT &
