#!/bin/bash
clear

DB_FILE="./data/player.csv"
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
read -p "Input Email: " email
read -p "Input Password: " password
echo

if [[ ! -f "$DB_FILE" ]]; then
   echo "DB belum dibuat! Proses masuk ke Register"
   sleep 2
   bash "./register.sh"
   exit 1
fi
if grep -q "^$email," "$DB_FILE"; then
    echo "✅ Email ditemukan"
    hashed_password=$(echo -n "${password}STATIC_SALT" | sha256sum | awk '{print $1}')

    if awk -F ',' -v e="$email" -v h="$hashed_password" '$1 == e && $3 == h { found=1 } END { exit !found }' "$DB_FILE"; then
        echo "✅ Login berhasil!"
    else
        echo "❌ Password salah!"
	exit 1
    fi
else
    echo "❌ Email tidak ditemukan!"
    exit 1
fi

sleep 2
bash "./scripts/manager.sh"
