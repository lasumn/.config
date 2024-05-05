#!/usr/bin/env bash
if pgrep blueman-applet > /dev/null
then
    pkill -f blueman-applet
else
    blueman-applet &
fi
