#!/usr/bin/env bash

# CPU usage % (calculated over a 0.3s delta for real-time accuracy)
cpu=$(awk '
NR==1{u=$2+$4; t=$2+$4+$5}
NR==2{u2=$2+$4; t2=$2+$4+$5}
END{printf "%.0f", (u2-u)/(t2-t)*100}
' <(grep "^cpu " /proc/stat) <(sleep 0.3; grep "^cpu " /proc/stat))

# RAM usage
ram=$(free | awk '/Mem:/ {printf "%.0f", $3/$2*100}')

# GPU Usage
gpu=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)

# Temperature
temp=$(sensors 2>/dev/null | awk '/Package id 0/ {print $4}')

text=" ${cpu}%"
tooltip="CPU: ${cpu}%\nRAM: ${ram}%\nGPU: ${gpu}%\nTemp: ${temp}"

printf '{"text":"%s","tooltip":"%s"}\n' "$text" "$tooltip"