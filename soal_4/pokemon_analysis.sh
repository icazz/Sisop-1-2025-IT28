#!/bin/bash
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<'EOF'
                                ,▄█▄
                                        ▄█▀ ▓█
           ,▄▄▄▓▓▓▄▄,     ,▄▄▓▓████▄, ▄██▄██▄ ,▄▄▄▄██▀▀█U   ,▄▄,
       ▄▄█▀╙        ▀█Ç  ▐██▄  ▐█"  ▀██▀▀' '▀▀██▌  '█  ▐▌   ██▌▀▀▀███▄▄▄,
      ╙██▌      ╥▄▄  ]█ ,▐███      ▄██  ▌▓█ ▄███    ⁿ   █▄▄Ñ███   '██   █C
        ████▄   └█▐▌ ▄█▀▐@ ╙▀▌   -███▌  ▀╙»▀▀╙██,      ▄█¬█╜ ,└█   ▓Ü  █▌
         ▀▀██▄   ╙"╓██  ██▄▓ ▓▌ ▄    ▀█▄   ,▄▄█▌  ▓▄ ▄¬█  ▀██▀ █D¿ `  ▐█
           ╙██▄   ███▌   '  ,█  ████▄, ╙▀██▀▀██▄▄▄████ █▄    ,▓▀ ▌   ┌█
            ╙██▄  └████▄,,▄▓██,╓█C ▀▀███▄█P  ╙▀▀▀▀▀███▄▄▄█████Ç ]█   █╩
             ▐██▄  ▓▌╙▀▀▀▀╙└▀▀▀▀▀      ╙▀▀          ╙▀▀▀▀█▀ ▀▀████  ▓▌
              ▐████▀▀                                           ▀████ `

EOF
cat << 'EOF'
 ---------------------------------------------------------------------------------------
| Usage: ./pokemon_analysis1.sh <file_name> [options]                                   |
|                                                                                       |
| Options:                                                                              |
| -h, --help    Display this help message.                                              |
| -i, --info    Show the highest adjusted and raw usage.                                |
| -s, --sort <col>  Sort data by column							|
| -g, --grep <name> Search for a specific Pokemon by name.                              |
| -f, --filter <type> Filter Pokemon by type.                                           |
| column you can call to the command:							|
| + Pokemon	+ Type2	  + SpDef							|
| + Usage%	+ HP	  + SpAtk							|
| + RawUsage	+ Atk	  + Speed							|
| + Type1	+ Def									|
 ---------------------------------------------------------------------------------------
EOF
    exit 0
fi

# Menentukan file yang diberikan sebagai argumen pertama
FILE="$1"
OPTION="$2"
ARGUMENT="$3"

# Jika file tidak diberikan atau tidak ditemukan, munculin pesan error
if [[ -z "$FILE" || ! -f "$FILE" ]]; then
    echo "Error: File not found or not specified."
    echo "Usage: ./pokemon_analysis1.sh <file_name> [options]"
    exit 1
fi

case "$OPTION" in
    -i|--info)
    echo "Summary of $FILE"
    
    maxUsageLine=$(awk -F',' 'NR>1 { print }' "$FILE" | sort -t',' -k2 -n -r | head -n 1)
    maxPokemon=$(echo "$maxUsageLine" | cut -d',' -f1)
    maxUsage=$(echo "$maxUsageLine" | cut -d',' -f2)
    
    maxRawLine=$(awk -F',' 'NR>1 { print }' "$FILE" | sort -t',' -k3 -n -r | head -n 1)
    maxRawPokemon=$(echo "$maxRawLine" | cut -d',' -f1)
    maxRaw=$(echo "$maxRawLine" | cut -d',' -f3)
    
    echo "_____________________________________________________________"
    echo "| Summary of $FILE"
    echo "| Highest Adjusted Usage: $maxPokemon with $maxUsage% uses"
    echo "| Highest Raw Usage:      $maxRawPokemon with $maxRaw uses"
    echo "_____________________________________________________________"
    ;;

    -s|--sort)
    if [[ -z "$ARGUMENT" ]]; then
        echo "Error: Sorting column not specified."
        exit 1
    fi

    column=$(head -1 "$FILE" | awk -F',' -v arg="$ARGUMENT" '{for(i=1;i<=NF;i++){ if(tolower($i)==tolower(arg)) print i}}')
    if [ -z "$column" ]; then
        echo "Error: Invalid sorting column"
        exit 1
    fi

    echo "_____________________________________________________________"
    echo "| Sorting by column: $ARGUMENT"
    echo "-------------------------------------------------------------"
    if [[ "$column" -eq 1 ]]; then
        awk -F',' 'BEGIN { OFS="," } NR>1 { print }' "$FILE" | sort -t',' -k"$column","$column" -n
    else
        awk -F',' 'BEGIN { OFS="," } NR>1 { print }' "$FILE" | sort -t',' -k"$column","$column" -n -r
    fi
    echo "_____________________________________________________________"
    ;;


    -g|--grep)
    	if [[ -z "$ARGUMENT" ]]; then
           echo "Error: Pokemon name not specified."
           exit 1
    	fi

    	echo "_____________________________________________________________"
    	echo "| Searching for Pokemon with name: $ARGUMENT"
    	echo "-------------------------------------------------------------"
		awk -F',' 'NR>1 { print }' "$FILE" | awk -F',' -v name="$ARGUMENT" 'tolower($1) ~ tolower(name)' | sort -t',' -k2 -n -r
    	echo "_____________________________________________________________"
    	;;

    -f|--filter)
    	if [[ -z "$ARGUMENT" ]]; then
           echo "Error: Pokemon type not specified."
           exit 1
    	fi

    	echo "_____________________________________________________________"
    	echo "| Filtering Pokemon by type: $ARGUMENT"
    	echo "-------------------------------------------------------------"
    	awk -F',' -v type="$ARGUMENT" '($4 ~ type) || ($5 ~ type)' "$FILE" | sort -t',' -k2 -n -r
    	echo "_____________________________________________________________"
    	;;

    *)
        echo "Error: Invalid option."
        echo "Usage: ./pokemon_analysis1.sh <file_name> [options]"
        exit 1
        ;;
esac
