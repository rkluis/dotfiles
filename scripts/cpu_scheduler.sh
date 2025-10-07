#!/bin/sh

BAT_STATUS=$(cat /sys/class/power_supply/BAT0/status)

if [ "$BAT_STATUS" = "Charging" ] || [ "$BAT_STATUS" = "Full" ]; then
    sudo cpupower frequency-set -g performance
else
    sudo cpupower frequency-set -g powersave
fi

