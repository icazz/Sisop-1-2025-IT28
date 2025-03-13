#!/bin/bash

REGISTER_SCRIPT="./register.sh"
LOGIN_SCRIPT="./login.sh"
MANAGER_SCRIPT="./scripts/manager.sh"

while true; do
    clear
    cat << "EOF"

                   ▄▄▄▄▄   ╒▄▄▄▄▄▄     ▄▄▄▄▄▄▄   ▄▄▄▄▄   ▄▄▄▄▄▄▄▄▄   ▄▄▄▄▄
                 ▐█═----██ ▐█⌐----██ ▐█------  ╟█-----█▌ ██------  ██----¬█▌
                 ▐█▄▄▄▄▄██ ▐█▄▄▄▄▄▀▀ ▐█        ╟█▄▄▄▄▄█▌ ██▀▀▀▀▀   ██▄▄▄▄▄█▌
                 ▐█▀▀▀▀▀██ ▐█▀▀▀▀▀▄▄ '▀▄▄▄▄▄▄▄ ╟█▀▀▀▀▀█▌ ██▄▄▄▄▄▄▄ ██▀▀▀▀▀█▌
 ,,, c          -      -  -     ``   ------   -     -   -------   -     -              ,,,
 ▀▀▀▀▀                                                                                '▀▀▀▀
            ████████  ████████ j██████⌐  ▐█     ██ ▐████L ██     █F   ████▌   █▌
               ██    ¬█▌,,,,   ▐█⌐    ██ ▐███,▐███   ██   ███▌, ¬█▌ █▌    ▐█U █▌
               ██    ¬█▀▀▀▀▀'  ▐█▄▄▄▄▄▀▀ ▐█- ▀▀ ██   ██   ██ ╙▀▄▄█▌ ██▄▄▄▄▄█U █▌
               ██    ¬████████ ▐█▀¬¬¬¬██ ▐█-    ██ ▐████L ██   ¬▐█▌ ██¬¬¬¬▐█U ¬▐██████`
▌

============================================================================================
EOF

    echo "1) Register"
    echo "2) Login"
    echo "3) Crontab Manager"
    echo "4) Exit"
    echo "
============================================================================================
"
    read -p "Enter your choice [1-4]: " choice

    case "$choice" in
        1)
            echo "=== Register ==="
            if [ -f "$REGISTER_SCRIPT" ]; then
                bash "$REGISTER_SCRIPT"
            else
                echo "Error: $REGISTER_SCRIPT not found!"
            fi
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
        2)
            echo "=== Login ==="
            if [ -f "$LOGIN_SCRIPT" ]; then
                bash "$LOGIN_SCRIPT"
            else
                echo "Error: $LOGIN_SCRIPT not found!"
            fi
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
        3)
            echo "=== Crontab Manager ==="
            if [ -f "$MANAGER_SCRIPT" ]; then
                bash "$MANAGER_SCRIPT"
            else
                echo "Error: $MANAGER_SCRIPT not found!"
            fi
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
        4)
            echo "Exiting Arcaea Terminal. Goodbye!"
            exit 0
            ;;
        *)
            echo "Invalid option."
            read -n 1 -s -r -p "Press any key to continue..."
            ;;
    esac
done
