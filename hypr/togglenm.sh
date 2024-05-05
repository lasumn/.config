#!/usr/bin/env bash

if pgrep nm-applet > /dev/null
then
    pkill -f nm-applet
else 
    nm-applet --indicator &
fi
