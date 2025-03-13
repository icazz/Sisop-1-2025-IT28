#!/bin/bash

clear
RESET='\033[0m'
# Warna teks
PINK='\033[38;5;218m'
BLUE='\033[38;5;117m'
GREEN='\033[38;5;120m'
YELLOW='\033[38;5;221m'
PURPLE='\033[38;5;183m'
COLORS=("$PINK" "$BLUE" "$GREEN" "$YELLOW" "$PURPLE")

speak_to_me(){
    tput civis
    
    cat << "EOF"


    ░█▀█░█▀▀░█▀▀░▀█▀░█▀▄░█▄█░█▀█░▀█▀░▀█▀░█▀█░█▀█░█▀▀░░░▀█▀░█▀█░█▀▄░█▀█░█░█
    ░█▀█░█▀▀░█▀▀░░█░░█▀▄░█░█░█▀█░░█░░░█░░█░█░█░█░▀▀█░░░░█░░█░█░█░█░█▀█░░█░
    ░▀░▀░▀░░░▀░░░▀▀▀░▀░▀░▀░▀░▀░▀░░▀░░▀▀▀░▀▀▀░▀░▀░▀▀▀░░░░▀░░▀▀▀░▀▀░░▀░▀░░▀░

EOF
    while true; do
        COLOR=${COLORS[RANDOM % ${#COLORS[@]}]}
        affirmation=$(  curl -s https://www.affirmations.dev | sed -E 's/\{"affirmation":"//; s/"\}//')
        echo -e "${COLOR}    $affirmation${RESET}"
        sleep 1
    done
}

on_the_run(){
    clear
    tput civis
    cat << "EOF"


                    _/_/_/                              _/           
                   _/    _/    _/_/      _/_/_/    _/_/_/  _/    _/  
                  _/_/_/    _/_/_/_/  _/    _/  _/    _/  _/    _/   
                 _/    _/  _/        _/    _/  _/    _/  _/    _/    
                _/    _/    _/_/_/    _/_/_/    _/_/_/    _/_/_/     
                                                             _/      
                                                        _/_/         
EOF
    sleep 0.5
    clear
    cat << "EOF"


                      _/_/_/              _/     
                   _/          _/_/    _/_/_/_/  
                    _/_/    _/_/_/_/    _/       
                       _/  _/          _/        
                _/_/_/      _/_/_/      _/_/     
EOF
    sleep 0.5
    clear
    cat << "EOF"


                     _/_/_/            _/  
                  _/          _/_/    _/   
                 _/  _/_/  _/    _/  _/    
                _/    _/  _/    _/         
                 _/_/_/    _/_/    _/      



EOF
    length=$(($(tput cols) - 7))
    [ $length -lt 10 ] && length=10

    for i in $(seq 1 100); do
        
        sleep $(awk -v min=0.1 -v max=1 'BEGIN{srand(); print min+rand()*(max-min)}')

        progress=$((i * length / 100))
        progress_bar=$(printf "%0.s#" $(seq 1 $progress))

        printf "\r[%-${length}s] %3d%%" "$progress_bar" "$i"
    done
    echo ""
    echo ""
    echo "              Completed! 🎉"
    echo ""
}

time_function(){
    tput civis
    clear
    prev_rows=$(tput lines)
    prev_cols=$(tput cols)
    while true; do

        rows=$(tput lines)
        cols=$(tput cols)
        if [[ $rows -ne $prev_rows || $cols -ne $prev_cols ]]; then
            clear
            prev_rows=$rows
            prev_cols=$cols
        fi

        center_row=$((rows / 2 + 2))
        center_col=$((cols / 2 - 14))
        center_ascii=$((cols / 2 - 22))
        COLOR=${COLORS[RANDOM % ${#COLORS[@]}]}

        ascii_top=$((rows / 7))  # Atur posisi lebih ke atas
        tput cup $ascii_top $center_ascii
        echo " ███████████ █████ ██████   ██████ ██████████"
        tput cup $((ascii_top + 1)) $center_ascii
        echo "░█░░░███░░░█░░███ ░░██████ ██████ ░░███░░░░░█"
        tput cup $((ascii_top + 2)) $center_ascii
        echo "░   ░███  ░  ░███  ░███░█████░███  ░███  █ ░ "
        tput cup $((ascii_top + 3)) $center_ascii
        echo "    ░███     ░███  ░███░░███ ░███  ░██████   "
        tput cup $((ascii_top + 4)) $center_ascii
        echo "    ░███     ░███  ░███ ░░░  ░███  ░███░░█   "
        tput cup $((ascii_top + 5)) $center_ascii
        echo "    ░███     ░███  ░███      ░███  ░███ ░   █"
        tput cup $((ascii_top + 6)) $center_ascii
        echo "    █████    █████ █████     █████ ██████████"
        tput cup $((ascii_top + 7)) $center_ascii
        echo "   ░░░░░    ░░░░░ ░░░░░     ░░░░░ ░░░░░░░░░░ "

        tput cup $center_row $center_col
        echo -e "${COLOR}╔═════════════════════════════╗${RESET}"
        
        tput cup $((center_row + 1)) $center_col
        tput el  # Hapus isi baris tanpa menghapus seluruh layar
        echo -ne "${COLOR}║     ${RESET}"
        echo -ne "${WHITE}$(date '+%Y-%m-%d %H:%M:%S')"
        echo -e  "${COLOR}     ║${RESET}"

        tput cup $((center_row + 2)) $center_col
        echo -e "${COLOR}╚═════════════════════════════╝${RESET}"


        sleep 1
    done
}

money(){
    symbols=('€' '£' '¥' '¢' '₹')
    colors=(5 6 7)
    clear

    cols=$(tput cols)
    rows=$(tput lines)
    declare -A positions

    for ((i = 0; i < cols; i++)); do
        positions[$i]=$((RANDOM % rows))
    done

    # Loop animasi
    while true; do
        for ((i = 0; i < cols / 2; i++)); do
            col=$((RANDOM % cols))

            symbol="${symbols[RANDOM % ${#symbols[@]}]}"
            color="${colors[RANDOM % ${#colors[@]}]}"

            tput cup "${positions[$col]}" "$col"
            echo " "

            new_pos=$((positions[$col] - 2))
            if (( new_pos < 0 )); then new_pos=$rows; fi
            positions[$col]=$new_pos

            # Set warna
            tput setaf $color
            if (( RANDOM % 10 < 3 )); then
                tput bold
            fi

            tput cup "$new_pos" "$col"
            echo -n "$symbol"

            # Reset warna
            tput sgr0
        done
        sleep 0.0000000001
    done
}

brain_damage(){
    clear
    while true; do
        tput civis
        echo "### Task Manager - Brain Damage ###"
        echo "Time: $(date)"
        echo "-----------------------------------"

        ps -eo pid,user,comm,%cpu,%mem,time --sort=-%cpu | head -6

        echo "-----------------------------------"

        sleep 1
        clear
    done
}

# main program
TRACK=$1
TRACK=${TRACK//--play=/}

case "$TRACK" in
    "Speak to Me")
    speak_to_me
    ;;
    "On the Run")
    on_the_run
    ;;
    "Time")
    time_function
    ;;
    "Money")
    money
    ;;
    "Brain Damage")
    brain_damage
    ;;
    *)
    echo "Track tidak dikenali! Pilih antara 'Speak to Me', 'On the Run', 'Time', 'Money', 'Brain Damage'."
    ;;
esac