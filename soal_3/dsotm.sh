#!/bin/bash

clear

speak_to_me(){
    while true; do
        affirmation=$(curl -s https://www.affirmations.dev | sed -n 's/.*"affirmation":"\(.*\)".*/\1/p')
        echo -e "$affirmation"
        sleep 1
    done
}

on_the_run(){
    ./../progress_bar.sh
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
    ./../hujan.sh
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