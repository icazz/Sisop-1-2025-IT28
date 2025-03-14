#!/bin/bash
# frag_monitor.sh - Monitoring RAM dan menyimpan log

LOG_DIR="$(dirname "$(realpath "$0")")/../logs"
LOG_FILE="$LOG_DIR/fragment.log"

# Buat folder log jika belum ada
mkdir -p "$LOG_DIR"

# Fungsi mendapatkan penggunaan RAM
function get_ram_usage() {
    local mem_total mem_avail mem_used

    # Baca data RAM dari /proc/meminfo
    mem_total=$(grep -m1 "MemTotal" /proc/meminfo | awk '{print $2}')
    mem_avail=$(grep -m1 "MemAvailable" /proc/meminfo | awk '{print $2}')

    # Jika MemAvailable tidak ditemukan (fallback sistem lama)
    if [ -z "$mem_avail" ]; then
        local mem_free buffers cached
        mem_free=$(grep -m1 "MemFree" /proc/meminfo | awk '{print $2}')
        buffers=$(grep -m1 "Buffers" /proc/meminfo | awk '{print $2}')
        cached=$(grep -m1 "^Cached" /proc/meminfo | awk '{print $2}')
        mem_avail=$((mem_free + buffers + cached))
    fi

    # Hitung RAM yang terpakai
    mem_used=$((mem_total - mem_avail))

    # Konversi ke MB
    local total_mb=$((mem_total / 1024))
    local avail_mb=$((mem_avail / 1024))
    local used_mb=$((mem_used / 1024))

    # Hitung persentase penggunaan RAM
    local usage_percent
    usage_percent=$(awk -v used="$mem_used" -v total="$mem_total" 'BEGIN {printf "%.2f", (used / total * 100)}')

    echo "$usage_percent $used_mb $total_mb $avail_mb"
}

# Ambil timestamp
timestamp=$(date "+%Y-%m-%d %H:%M:%S")

# Dapatkan RAM usage
read ram_percent ram_used ram_total ram_avail <<< "$(get_ram_usage)"

# Cetak ke log file dengan format yang benar
echo "[$timestamp] - Fragment Usage [$ram_percent%] - Fragment Count [$ram_used MB] - Details [Total: $ram_total MB, Available: $ram_avail MB]" >> "$LOG_FILE"
