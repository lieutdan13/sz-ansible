#!/usr/bin/env bash

set -euo pipefail

xrandr --output DP-1 --auto
xrandr --output LVDS-1 --auto
xrandr --output DP-1 --left-of LVDS-1
