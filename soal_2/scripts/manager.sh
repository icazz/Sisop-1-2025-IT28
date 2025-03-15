#!/bin/bash

CORE_SCRIPT="$(realpath "$(dirname "$0")/core_monitor.sh")"
FRAG_SCRIPT="$(realpath "$(dirname "$0")/frag_monitor.sh")"

function remove_task() {
    local script=$1
    local task_name=$2

    if crontab -l 2>/dev/null | grep -q "$script"; then
        crontab -l 2>/dev/null | grep -v "bin/bash .*$(realpath "$script")" | crontab -
        echo "🗑️ $task_name successfully removed from crontab!"
    else
        echo "❌ $task_name not found in crontab!"
    fi

    local pids=$(pgrep -f "$script")
    if [[ -n "$pids" ]]; then
        echo "🛑 Stopping $task_name..."
        kill -9 $pids
        echo "✅ $task_name successfully stopped!"
    fi
}

function add_cron() {
    local script=$1
    local task_name=$2

    if crontab -l 2>/dev/null | grep -q "$script"; then
        echo "❌ $task_name is already in crontab!"
        return
    fi

    (crontab -l 2>/dev/null | grep -v "bin/bash .*$(realpath "$script")"; echo "* * * * * /bin/bash $(realpath "$script")") | crontab -
    echo "✅ $task_name successfully added to crontab every 1 minute!"
}

function list_cron() {
    local cron_jobs=$(crontab -l 2>/dev/null)
    if [[ -z "$cron_jobs" ]]; then
        echo "📜 No scheduled tasks in crontab!"
    else
        echo "📜 Active crontab tasks:"
        echo "$cron_jobs"
    fi
}

while true; do
    clear
    echo "=================================================="
    echo "            ARCAEA TERMINAL - MONITORING          "
    echo "=================================================="
    echo " ID | OPTION                                      "
    echo "----|--------------------------------------------"
    echo " 1  | Add CPU - Core Monitor to Crontab          "
    echo " 2  | Add RAM - Fragment Monitor to Crontab      "
    echo " 3  | Remove CPU - Core Monitor                  "
    echo " 4  | Remove RAM - Fragment Monitor              "
    echo " 5  | View ALL Scheduled Monitoring Jobs         "
    echo " 6  | Exit Arcaea Terminal                       "
    echo "=================================================="
    read -p "Enter option [1-6]: " choice

    case $choice in
        1) add_cron "$CORE_SCRIPT" "CPU Monitoring" ;;
        2) add_cron "$FRAG_SCRIPT" "RAM Monitoring" ;;
        3) remove_task "$CORE_SCRIPT" "CPU Monitoring" ;;
        4) remove_task "$FRAG_SCRIPT" "RAM Monitoring" ;;
        5) list_cron ;;
        6) echo "🚪 Exiting Arcaea Terminal."; exit 0 ;;
        *) echo "❌ Invalid option! Please enter a number between 1-6." ;;
    esac
    read -p "Press Enter to continue..."
done
