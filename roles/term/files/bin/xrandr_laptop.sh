#!/usr/bin/env bash

set -euo pipefail

xrandr_out=`xrandr`
echo $xrandr_out | grep 'eDP1 connected' 2>&1 >/dev/null
if [ $? -eq 0 ]; then
    LAPTOP_DISPLAY=eDP1
else
    LAPTOP_DISPLAY=eDP2
fi

echo $xrandr_out | grep 'DP1 connected' 2>&1 >/dev/null
if [ $? -eq 0 ]; then
    VGA_CONF="--output DP1 --auto --right-of $LAPTOP_DISPLAY"
else
    VGA_CONF='--output P1 --off'
fi

echo $xrandr_out | grep 'VGA1 connected' 2>&1 >/dev/null
if [ $? -eq 0 ]; then
    VGA_CONF="--output VGA1 --auto --right-of $LAPTOP_DISPLAY"
else
    VGA_CONF='--output VGA1 --off'
fi

echo $xrandr_out | grep 'HDMI1 connected' 2>&1 >/dev/null
if [ $? -eq 0 ]; then
    HDMI_CONF="--output HDMI1 --auto --right-of $LAPTOP_DISPLAY"
else
    HDMI_CONF='--output HDMI1 --off'
fi

xrandr --output $LAPTOP_DISPLAY --auto $VGA_CONF $HDMI_CONF &
