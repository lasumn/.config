#!/usr/bin/env bash

governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)

case $governor in
    "performance")
        printf '{"text": "", "alt": "", "tooltip": "performance", "class": "", "percentage": ""}'
    ;;
    "powersave")
        printf '{"text": "", "alt": "", "tooltip": "powersave", "class": "", "percentage": ""}'
    ;;
esac

