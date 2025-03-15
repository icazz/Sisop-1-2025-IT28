#!/bin/bash
clear

DB_FILE="./data/player.csv"


cat << "EOF"
               ,▄▀▀▀▀▄, ██▀▀▀▀▄  ▄▀▀▀▀▀▀ ▄▐▀▀▀▀▄  █▀▀▀▀▀▀ ,▄▀▀▀▀▄
               ▐█    █▌ █▌    █-▐█       █▌    █⌐ █████L  ██    █▌
               ▐█▀▀▀▀█▌ ██▀▀▀▀▄ └▀▄▄▄▄▄▄ ██▀▀▀▀█⌐ █▄▄▄▄▄▄ ██▀▀▀▀█▌
    ,,,,,       ¬    -` ¬     ¬   ¬¬¬¬¬- -     ¬  ¬¬¬¬¬¬¬ `-    ¬      ,,,,,
    ▀▀▀▀▀"                                                             ▀▀▀▀▀^
                ▄╚▀▀▀▀▀ ▐▀██▀ ╓▐▀▀▀▀▀─ █▄,  ▐█     ▐█    ██ ██▀▀▀▀▄
                ▀████▌    █U  █▌ ████⌐ █▀▐█ ▐█     ▐█    ██ █▌    █⌐
                ▄▄▄▄▄▄▀ ,▄█▄▄ ▀▌▄▄▄▄█U █   ▀██     ╘▀▄▄▄▄▀▀ ██▀▀▀▀
                ¬¬¬¬¬-   ¬¬¬`   ¬¬¬¬¬  ¬     ¬       ¬¬¬¬   -`
_____________________________________________________________________
EOF

if [ ! -f "$DB_FILE" ]; then
    mkdir -p ./data
    echo "email,username,hpassword,password" > "$DB_FILE"
fi

validate_input() {
    local valid=0
    while [ $valid -eq 0 ]; do

        read -p "Enter Username: " username
        read -p "Enter Email: " email
        read -s -p "Enter Password: " password
        echo ""
        echo "_____________________________________________________________________"

        valid=1  # Anggap valid, cek error nanti

        # Cek apakah email sudah digunakan
        if grep -q "^$email," "$DB_FILE"; then
            echo "Error: Email already taken!"
            valid=0
        fi

        # Validasi Email: harus mengandung '@' dan '.'
        if [[ "$email" != *"@"* || "$email" != *"."* ]]; then
            echo "Error: Email must contain '@' and '.'"
            valid=0
        fi

        # Validasi Password
        if [ ${#password} -lt 8 ]; then
            echo "Error: Password must be at least 8 characters long."
            valid=0
        fi
        if ! [[ "$password" =~ [A-Z] ]]; then
            echo "Error: Password must include at least one uppercase letter."
            valid=0
        fi
        if ! [[ "$password" =~ [a-z] ]]; then
            echo "Error: Password must include at least one lowercase letter."
            valid=0
        fi
        if ! [[ "$password" =~ [0-9] ]]; then
            echo "Error: Password must include at least one number."
            valid=0
        fi

        # Jika ada error, ulangi input
        if [ $valid -eq 0 ]; then
            echo "Please try again."
            echo "_____________________________________________________________________"
        fi
    done
}

validate_input

hashed_password=$(echo -n "${password}STATIC_SALT" | sha256sum | awk '{print $1}')

echo "$email,$username,$hashed_password,$password" >> "$DB_FILE"
echo "Registration successful!"
