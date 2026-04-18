#!/usr/bin/env sh

# CPU usage %
cpu=$(grep 'cpu ' /proc/stat | awk '{u=$2+$4; t=$2+$4+$5} END {printf "%.0f", (u/t)*100}')

# RAM usage
ram=$(free | awk '/Mem:/ {printf "%.0f", $3/$2*100}')

# GPU Usage
gpu=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)

# Temperature
temp=$(sensors 2>/dev/null | awk '/Package id 0/ {print $4}')

text="${cpu}%"
tooltip="CPU: ${cpu}%\nRAM: ${ram}%\nGPU: ${gpu}%\nTemp: ${temp}"

printf '{"text":"%s","tooltip":"%s"}\n' "$text" "$tooltip"
