#!/bin/bash
# frag_monitor.sh
# Variabel global untuk menyimpan data CPU sebelumnya
PREV_TOTAL=0
PREV_IDLE=0

function get_cpu_usage() {
  read cpu user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
  local total=$((user + nice + system + idle + iowait + irq + softirq + steal + guest + guest_nice))
  
  # Hitung delta (selisih) sejak pembacaan sebelumnya
  local total_diff=$((total - PREV_TOTAL))
  local idle_diff=$((idle - PREV_IDLE))
  
  # Hitung persentase usage
  # usage = (total_diff - idle_diff) / total_diff * 100
  local usage=0
  if [ $total_diff -ne 0 ]; then
    usage=$(( (100 * (total_diff - idle_diff)) / total_diff ))
  fi
  
  # Simpan nilai total dan idle untuk pembacaan berikutnya
  PREV_TOTAL=$total
  PREV_IDLE=$idle
  
  echo "$usage"
}
# Fungsi: Membaca RAM usage via /proc/meminfo
# Menggunakan MemTotal dan MemAvailable (jika ada) untuk hitung persentase.
function get_ram_usage() {
  local mem_total
  local mem_avail
  
  # Baca MemTotal
  mem_total=$(grep -m1 "MemTotal" /proc/meminfo | awk '{print $2}')
  # Baca MemAvailable (jika tidak ada, kita akan gunakan fallback)
  mem_avail=$(grep -m1 "MemAvailable" /proc/meminfo | awk '{print $2}')
  
  # Fallback jika MemAvailable tidak ditemukan (beberapa distro lama)
  if [ -z "$mem_avail" ]; then
    local mem_free=$(grep -m1 "MemFree" /proc/meminfo | awk '{print $2}')
    local buffers=$(grep -m1 "Buffers" /proc/meminfo | awk '{print $2}')
    local cached=$(grep -m1 "^Cached" /proc/meminfo | awk '{print $2}')
    mem_avail=$((mem_free + buffers + cached))
  fi
  
  # Hitung usage
  local used=$((mem_total - mem_avail))
  # Persentase
  local usage_percent
  usage_percent=$(awk -v used="$used" -v total="$mem_total" 'BEGIN {printf "%.2f", (used / total * 100)}')
  # Konversi ke MB
  local used_mb=$((used / 1024))
  
  # Kembalikan string "xx.xx% (yyy MB)"
  echo "${usage_percent}% (${used_mb} MB)"
}

# Inisialisasi awal CPU (agar PREV_* terisi)
# Kita baca sekali data CPU, lalu sleep sejenak agar next read bisa dihitung selisihnya
get_cpu_usage >/dev/null
sleep 1

# Loop utama: streaming CPU & RAM usage
while true; do
  # Dapatkan CPU usage
  cpu_usage=$(get_cpu_usage)
  # Dapatkan RAM usage
  ram_usage=$(get_ram_usage)
  
  # Bersihkan layar
  clear
  cat << "EOF"
=============================================================================
                 ,,,,   ,,,,,     ,,,,,    ,,,,   ,,,,,,,   ,,,,
               ▄▌▀▀▀▀▄ ¬█▀▀▀▀}▄ ╔▄▀▀▀▀▀▀ ▄Γ▀▀▀▀▄ ▐█▀▀▀▀▀▀ ╔▄▀▀▀▀▄▄
               █▌,,,,█⌐¬█▄,,,▐█ ╟█       █▌,,,¿█`▐█████F  ██,,,,█▌
               █▌▀▀▀▀█⌐¬█▀▀▀▀▐▄ "▀▄▄▄▄▄▄ █▌▀▀▀▀█`▐█▄▄▄▄▄▄ ██▀▀▀▀█▌
   ╓▄▄▄▄▄                                                              ▄▄▄▄▄▄
   `-----                                                              -----`
                          █▀▀▀▀▀▀ ▐█▀▀▀▀▄▄ ▄▄▀▀▀▀▄  ▄▀▀▀▀▀▀
                          █████▌  ▐█    ██ █▌    █▌ █- ████
                          █▌      ▐█▀▀▀▀╦▄ ██▀▀▀▀█▌ ▀▄▄▄▄▄█
                          `        `             `    `````
=============================================================================
EOF

  echo "CPU Usage  : ${cpu_usage}%"
  echo "RAM Usage  : ${ram_usage}"
  echo "--------------------------------"
  echo "Press [CTRL+C] to exit."
  
  sleep 1
done
