#!/bin/bash
# scripts/manager.sh
# Menu interaktif untuk menambahkan/menghapus job crontab
# terkait pemantauan CPU (Core) dan RAM (Fragments).

# Lokasi skrip pemantauan (sesuaikan path)
CORE_MONITOR="$(dirname "$(readlink -f "$0")")/core_monitor.sh"
FRAG_MONITOR="$(dirname "$(readlink -f "$0")")/frag_monitor.sh"

# File log (sesuai instruksi, di ./log/)
CORE_LOG="./log/core.log"
FRAG_LOG="./log/fragment.log"

while true; do
    clear
    cat << "EOF"
========================================
          ARCAEA TERMINAL
========================================
 ID   | OPTION
----------------------------------------
 1)   Add CPU - Core Monitor to Crontab
 2)   Add RAM - Fragment Monitor to Crontab
 3)   Remove CPU - Core Monitor from Crontab
 4)   Remove RAM - Fragment Monitor from Crontab
 5)   View All Scheduled Monitoring Jobs
 6)   Exit Arcaea Terminal
----------------------------------------
EOF
    read -p "Enter option [1-6]: " opt

    case "$opt" in
        1)
            echo "Adding CPU - Core Monitor to Crontab..."
            crontab -l > /tmp/arc_temp_cron 2>/dev/null
            # Jalankan skrip setiap 5 menit, output ke core.log
            echo "*/5 * * * * $CORE_MONITOR >> $CORE_LOG 2>&1" >> /tmp/arc_temp_cron
            crontab /tmp/arc_temp_cron
            rm -f /tmp/arc_temp_cron
            echo "CPU Monitor job added!"
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
        2)
            echo "Adding RAM - Fragment Monitor to Crontab..."
            crontab -l > /tmp/arc_temp_cron 2>/dev/null
            # Jalankan skrip setiap 5 menit, output ke fragment.log
            echo "*/5 * * * * $FRAG_MONITOR >> $FRAG_LOG 2>&1" >> /tmp/arc_temp_cron
            crontab /tmp/arc_temp_cron
            rm -f /tmp/arc_temp_cron
            echo "RAM Monitor job added!"
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
        3)
            echo "Removing CPU - Core Monitor from Crontab..."
            crontab -l 2>/dev/null | grep -v "$CORE_MONITOR" > /tmp/arc_temp_cron
            crontab /tmp/arc_temp_cron
            rm -f /tmp/arc_temp_cron
            echo "CPU Monitor job removed!"
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
        4)
            echo "Removing RAM - Fragment Monitor from Crontab..."
            crontab -l 2>/dev/null | grep -v "$FRAG_MONITOR" > /tmp/arc_temp_cron
            crontab /tmp/arc_temp_cron
            rm -f /tmp/arc_temp_cron
            echo "RAM Monitor job removed!"
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
        5)
            echo "Current crontab jobs:"
            echo "----------------------------------------"
            crontab -l 2>/dev/null || echo "No crontab for current user."
            echo "----------------------------------------"
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
        6)
            echo "Exiting Arcaea Terminal. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option."
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
    esac
done
