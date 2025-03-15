#!/bin/bash

LOG_DIR="$(dirname "$(realpath "$0")")/../logs"
LOG_FILE="$LOG_DIR/core.log"

mkdir -p "$LOG_DIR"

# Fungsi mendapatkan penggunaan CPU dan model CPU
function get_cpu_usage() {
    local cpu_usage cpu_model

    # Ambil penggunaan CPU (idle di kolom ke-8)
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')

    # Ambil model CPU dari /proc/cpuinfo
    cpu_model=$(grep -m1 "model name" /proc/cpuinfo | cut -d ":" -f2 | sed 's/^[ \t]*//')

    # Jika gagal mendapatkan data, beri nilai default
    if [ -z "$cpu_usage" ]; then
        cpu_usage="N/A"
    fi
    if [ -z "$cpu_model" ]; then
        cpu_model="Unknown"
    fi

    echo "$cpu_usage $cpu_model"
}

timestamp=$(date "+%Y-%m-%d %H:%M:%S")

read cpu_percent cpu_model <<< "$(get_cpu_usage)"

echo "[$timestamp] - Core Usage [$cpu_percent%] - Terminal Model [$cpu_model]" >> "$LOG_FILE"
