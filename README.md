# Laporan Praktikum
## Soal_1
## Soal_2
## Soal_3
## Soal_4
### Langkah - Langkah
- Program shell pokemon_analysis.sh dibuat untuk membantu menganalisis data penggunaan Pokémon yang terdapat pada file CSV, misalnya pokemon_usage.csv. Data tersebut memuat informasi penting seperti nama Pokémon, persentase penggunaan (Usage%), jumlah penggunaan (RawUsage), tipe, dan statistik (HP, Atk, Def, Sp.Atk, Sp.Def, Speed). Program ini ditujukan untuk memudahkan persiapan tim dalam turnamen “Generation 9 OverUsed 6v6 Singles” dengan menampilkan informasi meta secara ringkas dan terurut.
1. Mempersiapkan workspace
```
mkdir soal_4 && cd soal_4 && wget https://drive.usercontent.google.com/u/0/uc?id=1n-2n_ZOTMleqa8qZ2nB8ALAbGFyN4-LJ&export=download -O pokemon_analysis.csv
nano pokemon_analysis.sh
```
### Fitur Utama:
1. Summary Data, Menampilkan ringkasan data dari Pokemon dengan Highest Adjusted Usage (Usage% tertinggi), serta Pokemon dengan Highest Raw Usage (jumlah penggunaan terbanyak)
2. Sorting Data, Mengurutkan seluruh data berdasarkan kolom yang diinginkan, antara lain: { Pokemon, Usage%, RawUsage, Hp, Atk, Def, SpAtk, SpDef, Speed, Type1, Type2} secara descending (dari kecil ke besar)
3. Pencarian, Mencari Pokémon berdasarkan nama secara case-insensitive, yang memastikan ditampilkannya Pokemon yang sesuai dengan keyword yang dicari.
4. Filter, Memungkinkan pengguna untuk memfilter data berdasarkan tipe (misal: Dark, Electric, dsb.), sehingga hanya Pokemon dengan tipe yang sesuai yang ditampilkan.
5. Help Page, Tampilan yang berisi penjelasan fitur dari program shell ini

#### command untuk menjalankan program: 
```
./pokemon_analysis.sh [nama file csv] [option] [argumen]
```

2. Membuat fitur help page
```
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

FILE="$1"
OPTION="$2"
ARGUMENT="$3"
```
- `if [[ "$1" == "-h" || "$1" == "--help" ]];then . . . fi` bagian ini merupakan gerbang, yang apabila flag / optionnya adalah -h atau --help, maka bagian help ini akan jalan
- `cat << 'EOF' . . . EOF` bagian ini mengeluarkan baris yang ada di antara cat << 'EOF' sampai EOF
- `exit 0` adalah tanda berakhirnya program tanpa eror
- `FILE="$1" OPTION="$2" ARGUMENT="$3"` bagian ini menginisiasi urutan input dari command seperti
`./pokemon_analysis.sh [nama file csv] [option] [argumen]`

```
if [[ -z "$FILE" || ! -f "$FILE" ]]; then
    echo "Error: File not found or not specified."
    echo "Usage: ./pokemon_analysis1.sh <file_name> [options]"
    exit 1
fi
```
- error handling agar mengakhiri sesi dan mengeluarkan pesan apabila file tidak ditemukan

3. Membuat fitur summary
```
case "$OPTION" in
    -i|--info)
        echo "Summary of $FILE"	
	awk -F ',' '
	   NR > 1 {
     	   	  if ($2 > maxUsage) {
      	   	    maxUsage = $2
       	   	    maxPokemon = $1
     	   	  }
    	   	  if ($3 > maxRaw) {
       	   	    maxRaw = $3
      	   	    maxRawPokemon = $1
     	   	  }
   	    	}
   	   END {
     		print "_____________________________________________________________"
     		print "| Summary of " FILENAME
     		print "| Highest Adjusted Usage: " maxPokemon, maxUsage "% uses    "
     		print "| Highest Raw Usage:      " maxRawPokemon, maxRaw, "uses    "
     		print "_____________________________________________________________"
   	       }' "$FILE"

        ;;
```
- Menggunakan switch case untuk menjadi gerbang nya, dan untuk fitur summary, menggunakan -i atau --info
- `awk -F ',' '` mendefinisikan pemisah kolomnya adalah (,)
- `NR > 1` Mulai dari baris ke 2 (>1) lakukan pencarian `Usage%` dan `RawUsage` terbesar
- mengeluarkan kesimpulan dari pencarian `Usage%` dan `RawUsage` data terbesarnya
```
{
  print "_____________________________________________________________"
  print "| Summary of " FILENAME
  print "| Highest Adjusted Usage: " maxPokemon, maxUsage "% uses    "
  print "| Highest Raw Usage:      " maxRawPokemon, maxRaw, "uses    "
  print "_____________________________________________________________"
}' "$FILE"
```
   
6. Membuat fitur Sorting
```
-s|--sort)
    	if [[ -z "$ARGUMENT" ]]; then
           echo "Error: Sorting column not specified."
           exit 1
    	fi
    	column=$(head -1 "$FILE" | awk -v arg="$ARGUMENT" -F',' '{for(i=1; i<=NF; i++) if ($i == arg) print i}')
	if [ -z "$column" ]; then
       	   echo "Error: Invalid sorting column"
       	   exit 1
    	fi

    	echo "_____________________________________________________________"
    	echo "| Sorting by column: $ARGUMENT"
    	echo "-------------------------------------------------------------"
    	awk -F',' 'NR>1 { print }' "$FILE" \
      | sort -t',' -fk"$column","$column"
	echo "_____________________________________________________________"
    ;;
```
- Menggunakan error handling, apabila Argumen nya tidak ada
```
if [[ -z "$ARGUMENT" ]]; then
     echo "Error: Sorting column not specified."
     exit 1
fi
```
- `column=$(head -1 "$FILE" | awk -v arg="$ARGUMENT" -F',' '{for(i=1; i<=NF; i++) if ($i == arg) print i}')`
+ `head -1 "$FILE"` mengambil baris pertama (header) dari file CSV.
+ `awk -F',' ...` membaca baris tersebut sebagai data yang dipisahkan koma.
+ Variabel `arg` di-pass dari Bash ke `awk (-v arg="$ARGUMENT")` untuk membandingkan tiap kolom ($i) dengan $ARGUMENT.
+ `-v` Berfungsi untuk mendefinisikan variabel AWK dari luar skrip. Misalnya, `-v arg="$ARGUMENT"` membuat variabel `arg` di dalam awk bernilai sama dengan `$ARGUMENT` di shell.
+ Jika kolom cocok, awk mencetak nomor kolomnya (print i) dan memasukkannya ke column.

- Error handling apabila column tidak ada di header file csv
```
if [ -z "$column" ]; then
    echo "Error: Invalid sorting column"
    exit 1
fi
```
```
awk -F',' 'NR>1 { print }' "$FILE" | sort -t',' -fk"$column","$column"
```
- `awk -F',' 'NR>1 { print }'` mencetak semua baris CSV kecuali baris pertama (header), dan hasilnya di-pipe ke perintah sort.
- `sort -t','` berarti pemisah kolom untuk sortir adalah tanda koma `(,)`.
- `-fk"$column","$column"` berarti sort dengan key (kunci) pada kolom `$column`, dengan `-f (fold case)` untuk mengabaikan perbedaan huruf besar/kecil.
  
8. Membuat fitur Pencarian
```
-g|--grep)
    	if [[ -z "$ARGUMENT" ]]; then
           echo "Error: Pokemon name not specified."
           exit 1
    	fi

    	echo "_____________________________________________________________"
    	echo "| Searching for Pokemon with name: $ARGUMENT"
    	echo "-------------------------------------------------------------"
    	grep -i "$ARGUMENT" "$FILE"
    	echo "_____________________________________________________________"
    	;;
```
- Error handling jika tidak ada argumen dalam command bash nya
```
if [[ -z "$ARGUMENT" ]]; then
     echo "Error: Pokemon name not specified."
     exit 1
fi
```
- `grep -i "$ARGUMENT" "$FILE"` mencari argumen dari file tanpa memperhatikan kapital/ tidak (case-insensitive)

10. Membuat fitur Filter
```
-f|--filter)
    	if [[ -z "$ARGUMENT" ]]; then
           echo "Error: Pokemon type not specified."
           exit 1
    	fi

    	echo "_____________________________________________________________"
    	echo "| Filtering Pokemon by type: $ARGUMENT"
    	echo "-------------------------------------------------------------"
    	awk -F',' -v type="$ARGUMENT" '$4 ~ type' "$FILE"
    	echo "_____________________________________________________________"
    	;;
```
- Error handling, menampilkan pesan error apabila argumen nya kosong
- `awk -F',' -v type="$ARGUMENT" '$4 ~ type' "$FILE"`  digunakan untuk filternya
- `-F','`: Menentukan bahwa pemisah (delimiter) dalam file CSV adalah tanda koma.
- `-v type="$ARGUMENT"`: Mengirimkan nilai dari $ARGUMENT ke variabel type di dalam AWK.
- `'$4 ~ type'`: Memeriksa setiap baris (kecuali header jika tidak diabaikan sebelumnya) dan memilih baris di mana kolom ke-4 (yang biasanya berisi tipe Pokémon) cocok dengan pola yang disimpan di variabel type. Operator ~ digunakan untuk pencocokan pattern (regex).
- `"$FILE"`: Menunjukkan nama file CSV yang berisi data Pokémon.
  
11. Error handling, apabila option tidak valid
```*)
        echo "Error: Invalid option."
        echo "Usage: ./pokemon_analysis1.sh <file_name> [options]"
        exit 1
        ;;
```
