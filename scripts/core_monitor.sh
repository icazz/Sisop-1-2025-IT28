#!/bin/bash
# core_monitor.sh
# Skrip streaming CPU usage dan model CPU (sebagai "terminal") secara real-time

# Ambil model CPU (hanya sekali)
cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d ':' -f2 | sed 's/^ //')

# Loop tak hingga untuk streaming
while true; do
    # Ambil CPU usage: hitung penggunaan CPU dari nilai idle
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{printf "%.3f%%", 100 - $1}')
    
    # Bersihkan layar untuk update tampilan
    clear
    
    # Tampilkan header dan informasi
    cat << "EOF"
======================================================================================
               ▄▄▀▀▀▀▄⌐ █▀▀▀▀▌▄ ┌▄▀▀▀▀▀▀ ▄/▀▀▀▀▄ ¬█▀▀▀▀▀▀ ▄▄▀▀▀▀▄⌐
               █▌    █▌ █,   ▐█ ▐█       █▌    █⌐¬█████▌  ██    █▌
               ██▀▀▀▀█▌ █▀▀▀▀▀▄ └▀▄▄▄▄▄▄ ██▀▀▀▀█⌐¬█▄▄▄▄▄▄ ██▀▀▀▀█▌
   ,,,,,,            -  -     -   -----  -     -  -------  `    -      ,,,,,,
   '▀▀▀▀▀                                                              ▀▀▀▀▀▀
                          ▄╘▀▀▀▀▀  ▄▀▀▀▀╗▄ ██▀▀▀▀▄  █▀▀▀▀▀▀
                          █▌      ▐█    ╟█ █▌    █▌ █████▌
                          ▀╕▄▄▄▄▄ ╘▀▄▄▄▄╚▀ ██▀▀▀▀▄  █▄▄▄▄▄▄
                            ¬¬¬¬¬   ¬¬¬¬   ¬¬    ¬  ¬¬¬¬¬¬¬
======================================================================================
EOF

    echo "Overall CPU Usage: $cpu_usage"
    echo "CPU Model        : $cpu_model"
    echo "Press [CTRL+C] to exit."
cat<<"EOF"
====================================================================================
EOF
    # Delay 1 detik sebelum update berikutnya
    sleep 1
done
