#!/usr/bin/env bash

wbg ~/.config/hypr/loki.png &

nm-applet -indicator &

blueman-applet &

waybar &

dunst &

mullvad-vpn & 

brightnessctl set 5%+

sleep 1

brightnessctl set 5%-

sleep 10

pkill -f waybar

