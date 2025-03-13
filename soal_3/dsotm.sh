#!/bin/bash

clear

speak_to_me(){
    tput civis
    while true; do
        affirmation=$(curl -s https://www.affirmations.dev | sed -E 's/\{"affirmation":"//; s/"\}//')
        echo -e "$affirmation"
        sleep 1
    done
}

on_the_run(){
    echo "Ready, set, go!"
    length=$(($(tput cols) - 7))
    [ $length -lt 10 ] && length=10

    for i in $(seq 1 100); do
        sleep 0.1

        progress=$((i * length / 100))
        progress_bar=$(printf "%0.s#" $(seq 1 $progress))

        printf "\r[%-${length}s] %3d%%" "$progress_bar" "$i"
    done
    echo "" 
}

time_function(){
    while true; do
    tput civis
    date "+%Y-%m-%d %H:%M:%S"
    sleep 1
    clear
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

            tput cup "$new_pos" "$col"
            echo -n "$symbol"

            # Reset warna
            tput sgr0
        done
        sleep 0.00000001
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