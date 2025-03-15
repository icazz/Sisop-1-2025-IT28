#!/bin/bash
clear

DB_FILE="./data/player.csv"
if [[ ! -f "$DB_FILE" ]]; then
   echo "Database not found! Redirecting to Registration."
   sleep 2
   bash "./register.sh"
   exit 1
fi
cat<<"EOF"
             ╒▄▀▀▀▀y▄ ██▀▀▀▀▄▄ ▄/▀▀▀▀▀- ▄▀▀▀▀▀▄ ▐█▀▀▀▀▀▀ ▄▄▀▀▀▀▄▄
             ▐█    ▐█ ██    █▌ █▌       █⌐   ▐█ ▐█████L  ██    █▌
             ▐█▀▀▀▀██ ██▀▀▀▀▄▄ ▀▌▄▄▄▄▄  █▀▀▀▀▀█ ▐█▄▄▄▄▄▄ ██▀▀▀▀█▌
   ,,,,,,     ¬     -  -    -    ¬¬¬¬¬  ¬     ¬  ¬¬¬¬¬¬-  `    -        ,,,,,
   ▀▀▀▀▀▀                                                               ▀▀▀▀▀▀
                    ▐█       ,▄▀▀▀▀▄, ,▐▀▀▀▀▀⌐ ▀██▀ j█▄   ▐█
                    ▐█       ██    █▌ █▌ ▄▄▄▄µ  ██  ▐█▀▐▄ ▐█
                    ▐▀╓╓╓╓╓╓ ╚█╓╓╓╓█▌ ▀▌╓▄▄▄█▌ ╓██╓ ▐█   ▀██
                      ▀▀▀▀▀▀   ▀▀▀▀    `▀▀▀▀▀  ▀▀▀▀  ▀    `▀
=============================================================================
EOF
read -p "Enter Email: " email
read -s -p "Enter Password: " password
echo

if grep -q "^$email," "$DB_FILE"; then
    echo "Email found."
    hashed_password=$(echo -n "${password}STATIC_SALT" | sha256sum | awk '{print $1}')

    if awk -F ',' -v e="$email" -v h="$hashed_password" '$1 == e && $3 == h { found=1 } END { exit !found }' "$DB_FILE"; then
        echo "Login successful!"
    else
        echo "Incorrect password!"
	exit 1
    fi
else
    echo "Email not found!"
    exit 1
fi
    echo ""

sleep 2
bash "./scripts/manager.sh"
