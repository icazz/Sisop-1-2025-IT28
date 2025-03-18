# Laporan Praktikum IT28
## Yuan Banny Albyan - 5027241027
## Ica Zika Hamizah - 5027241058
## Nafis Faqih Allmuzaky Maolidi - 5027241095

## Soal_1
""

## Soal_2
#### Buatlah dua shell script, login.sh dan register.sh, yang dimana database “Player” disimpan di /data/player.csv. Untuk register, parameter yang dipakai yaitu email, username, dan password. Untuk login, parameter yang dipakai yaitu email dan password.
`mkdir soal_2 && touch login.sh && touch register.sh` kemudian `cd soal_2 && nano register.sh`
### Untuk register.sh
inisiasi lokasi database `DB_FILE = "/data/player.csv`
```
if [ ! -f "$DB_FILE" ]; then
    bash "sudo mkdir $DB_FILE"
    echo "email,username,hpassword,password" > "$DB_FILE"
fi
```
membuat file player.csv dan memasukkan header, bila player.csv belum ada
`validate_input()` = fungsi untuk memvalidasi input untuk ketentuan (2.b)

#### Email harus memiliki format yang benar dengan tanda @ dan titik, sementara password harus memiliki minimal 8 karakter, setidaknya satu huruf kecil, satu huruf besar, dan satu angka
```
local valid=0
while [ $valid -eq 0 ]; do
```
boolean valid diset false, dan selama tidak valid akan meminta user untuk input dengan ketentuan yang ada.
membaca input dari user, dan set valid sebagai 1 (positive thinking user bisa masuk).
```
read -p "Input Username: " username
read -p "Input Email: " email
read -p "Input Password: " password
valid=1
```
constrain email (harus ada '@' dan '.'), dan jika email tidak sesuai, maka valid diset ke 0 lagi.
```
if [[ "$email" != *"@"* || "$email" != *"."* ]]; then
    echo "Error: Email must contain '@' and '.'"
    valid=0
fi
```
dari atas ke bawah, untuk constrain passwordnya, (minimal 8 karakter, ada uppercase, ada lowercase, ada angka)
```
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
```
#### login/register tidak bisa memakai email yang sama (email = unique)
menggunakan awk untuk membaca file player.csv, dengan flag -F (untuk menandakan pemisahnya ',' ) -v (untuk meng assign variabel global $email ke variabel awk Email untuk dicek mulai dari barus ke-2 `NR>1`
```
if awk -F',' -v Email="$email" 'NR>1 { if ($2 == Email) { exit 1 } }' "$DB_FILE"; then
    :  # Email belum didaftarkan, lanjutkan
else
    echo "Error: Email already taken!"
    valid=0
fi
```
#### Gunakan algoritma hashing sha256sum yang memakai static salt
```
hashed_password=$(echo -n "${password}STATIC_SALT" | sha256sum | awk '{print $1}')
```
kemudian masukkan ke DB_FILE `echo "$email,$username,$hashed_password,$password" >> "$DB_FILE"`

### Untuk bagian login.sh
inisiasi DB_FILE `DB_FILE="/data/player.csv"`
input email dan password 
```
read -p "Input Email: " email
read -p "Input Password: " password
```
echo / keluarkan output dengan percabangan:
- jika DB_FILE belum ada, maka keluarkan DB belum dibuat! Proses masuk ke Register, lalu diarahkan ke program register.sh setelah jeda 2 detik
- grep / mengambil elemen dari kolom pertama (karna email tempatnya di kolom pertama saat di register.sh), namun jika email bukan di kolom pertama, maka bisa diubah sintaksnya menjadi 
```
awk -F ',' -v e="$email" '$2 == e { found=1 } END { exit !found }' "$DB_FILE"
```
lalu diecho "email ditemukan"
- jika email ditemukan selanjutnya dicek apakah sama dengan yang ada di DB_FILES dengan mencocokkannya menggunakan awk dan hashing password dengan algoritma yang sama ketika register.
hashing:`hashed_password=$(echo -n "${password}STATIC_SALT" | sha256sum | awk '{print $1}')`
lalu cek menggunakan `awk -F ',' -v e="$email" -v h="$hashed_password" '$1 == e && $3 == h { found=1 } END { exit !found }' "$DB_FILE`
- jika email ada, kemudian email dan password benar maka output "login berhasil"
- jika email ada tapi awk salah, maka output "password salah"
- jika email tidak ditemukan output "email tidak ditemukan"
```
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
```
- jika login berhasil maka lanjut output "berhasil" lalu diarahkan ke scripts/manager.sh

#### Sistem harus dapat melacak penggunaan CPU (dalam persentase) Lokasi shell script: ./scripts/core_monitor.sh
`mkdir scripts && touch scripts/core-monitor.sh' lalu memasukkan command 
```
cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d ':' -f2 | sed 's/^ //')
```
berdasarkan stack overflow, kurang lebih: mengambil data dari /proc/cpuinfo (cpu info dari processor)
hasil grep nya itu `model name  : Intel(R) Core(TM) i7-9700 CPU @ 3.00GHz`, maka ditambahkan
head-1 untuk mengambil baris pertama nya saja `mengambil hanya baris pertama dari output grep.`
cut -d ':' delimiter dengan tanda ':'
-f2 ambil kolom kedua setelah delimiter `Intel(R) Core(TM) i7-9700 CPU @ 3.00GHz`
sed 's/^ //' untuk memanipulasi teks dengan `'s/^ //'` untuk menghapus spasi di awal teks jika ada

karna di sini program dapat memantau monitor secara terus menerus, maka dibuat loop
```
while true; do
   # Ambil CPU usage: hitung penggunaan CPU dari nilai idle
   cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{printf "%.3f%%", 100 - $1}') 
clear # Bersihkan layar untuk update tampilan
```
atau
```
while true; do
   # Ambil CPU usage: hitung penggunaan CPU dari nilai idle
   cpu_usage=$(awk '{u=$2+$4; t=$2+$4+$5; if (NR==1){u1=u; t1=t;} else print ($2+$4-u1) * 100 / (t-t1) "%"; }' \ <(grep 	'cpu ' /proc/stat) <(sleep 1;grep 'cpu ' /proc/stat)) # Bersihkan layar untuk update tampilan
clear # Tampilkan header dan informasi
```

#### RAM menjadi representasi dari “fragments” di dunia “Arcaea”, yang dimana dipantau dalam persentase usage, dan juga penggunaan RAM sekarang. Lokasi shell script: ./scripts/frag_monitor.sh
karna tadi belum masuk ke folder scripts, maka bisa 'cd scripts && touch frag_monitor.sh' atau touch scripts/frag_monitor.sh`

1. cpu usage
- Script membaca data dari `/proc/stat` untuk menghitung total waktu CPU yang digunakan dan waktu idle.
- Menggunakan perbedaan (delta) antara pembacaan sebelumnya dan pembacaan saat ini untuk menghitung persentase penggunaan CPU.

2. RAM usage
- Script membaca data dari `/proc/meminfo` untuk mendapatkan total memori (`MemTotal`) dan memori yang tersedia (`MemAvailable`).
- Jika `MemAvailable` tidak tersedia, script menggunakan fallback dengan menjumlahkan `MemFree`, `Buffers`, dan `Cached`.
- Menghitung persentase penggunaan RAM dan mengonversi nilai penggunaan ke MB.






## Soal_3
### Langkah - Langkah

1. Pertama buat sebuah script "dsotm.sh" yang didalamnya berisi lima fungsi sesuai track yaitu Speak to Me, On the Run, Time, Money, dan Brain Damage.
```sh
nano dsotm.sh
```

2. Membuat program utama yakni menggunakan switch case dan buat 5 fungsi sesuai track yang diminta
```sh
speak_to_me(){
    # a. Speak to Me
}
on_the_run(){
    # b. On the Run
}
time_function(){
    # c. Time
}
money(){
    # d. Money
}
brain_damage(){
    # e. Brain Damage
}
# main program
TRACK=$1
TRACK=${TRACK//--play=/}

case "$TRACK" in
    "Speak to Me") speak_to_me ;;
    "On the Run") on_the_run ;;
    "Time") time_function ;;
    "Money") money ;;
    "Brain Damage") brain_damage ;;
    *) echo "Unrecognized track! Please choose from 'Speak to Me', 'On the Run', 'Time', 'Money', 'Brain Damage'." ;;
esac
```
Variabel `TRACK` diisi dengan argumen pertama `$1` yang diberikan saat menjalankan script sedangkan ekspresi `TRACK=${TRACK//--play=/}` digunakan untuk mengganti teks dalam variabel sehingga `--play=` dihapus dari nilai `TRACK`.

3. Fungsi `speak_to_me` berisi fitur yang memanggil API [affirmations](ttps://github.com/annthurium/affirmations) untuk menampilkan word of affirmation setiap detik.
```sh
speak_to_me(){
    clear
    tput civis # Menyembunyikan kursor terminal
    
    while true; do
        affirmation=$(  curl -s https://www.affirmations.dev | sed -E 's/\{"affirmation":"//; s/"\}//')
        echo -e "$affirmation"
        sleep 1
    done
}
```
- Menggunakan `curl` untuk mengambil data JSON dari API [affirmations](ttps://github.com/annthurium/affirmations)
- Opsi `-s` (silent) digunakan agar output tidak menampilkan informasi unduhan
- `sed` digunakan untuk membersihkan JSON dan hanya mengambil teks afirmasinya
- `s/\{"affirmation":"//; s/"\}//` → Menghapus `{"affirmation":"` dan `"}`

4. Fungsi `on_the_run` berisi sebuah progress bar yang berjalan dari 0% hingga 100% dengan interval random (setiap progress bertambah dalam interval waktu yang random dengan range 0.1 detik sampai 1 detik)
```sh
on_the_run(){
    clear
    tput civis
    length=$(($(tput cols) - 7))
    [ $length -lt 10 ] && length=10

    for i in $(seq 1 100); do
        
        sleep $(awk -v min=0.1 -v max=1 'BEGIN{srand(); print min+rand()*(max-min)}')

        progress=$((i * length / 100))
        progress_bar=$(printf "%0.s#" $(seq 1 $progress))

        printf "\r[%-${length}s] %3d%%" "$progress_bar" "$i"
    done
}
```
`tput cols` mengambil jumlah kolom dalam terminal (lebar terminal) sedangkan `length` adalah panjang maksimum progress bar, dikurangi 7 karakter untuk ruang label persen (100%).

```sh
[ $length -lt 10 ] && length=10
```
Jika panjang progress bar kurang dari 10 karakter, maka dipaksa menjadi 10 karakter agar tetap terlihat dengan baik

```sh
for i in $(seq 1 100); do
```
Perulangan dari 1 hingga 100 untuk membuat progress bar dari 0% hingga 100%

```sh
sleep $(awk -v min=0.1 -v max=1 'BEGIN{srand(); print min+rand()*(max-min)}')
```
Menggunakan awk untuk menghasilkan angka acak antara 0.1 hingga 1 detik agar bergerak dengan kecepatan yang bervariasi tidak konstan.

```sh
progress=$((i * length / 100))
```
Menghitung jumlah karakter # yang harus ditampilkan sesuai dengan persentase `progress`

```sh
progress_bar=$(printf "%0.s#" $(seq 1 $progress))
```
`seq 1 $progress` untuk membuat urutan angka dari 1 hingga $progress sedangkan `printf "%0.s#"` untuk mencetak karakter `#` sebanyak jumlah angka yang dihasilkan oleh `seq`

```sh
printf "\r[%-${length}s] %3d%%" "$progress_bar" "$i"
```
`\r` untuk menimpa baris yang sama
`[%-${length}s]` untuk menampilkan progress bar dengan panjang dinamis.
`%3d%%` untuk menampilkan angka persen yang selalu memiliki lebar 3 karakter untuk alignment


5. Fungsi `time_function` berisi live clock yang menunjukkan tanggal, jam, menit dan detik
```sh
time_function(){
    clear
    tput civis
    while true; do
        echo -ne "$(date '+%Y-%m-%d %H:%M:%S')"
        sleep 1
    done
}
```
- `$(date '+%Y-%m-%d %H:%M:%S')` menghasilkan tanggal & waktu saat ini dalam format `YYYY-MM-DD HH:MM:SS`
- `sleep 1` memberikan delay selama 1 detik

6. Fungsi `money` merupakan program mirip cmatrix dengan simbol mata uang seperti `$ € £ ¥ ¢ ₹ ₩ ₿ ₣`
```sh
money(){
    clear
    symbols=('$' '€' '£' '¥' '¢' '₹' '₩' '₿' '₣')
    colors=(5 6 7)

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
        sleep 0.00000001
    done
}
```
`cols=$(tput cols)` untuk mengambil jumlah kolom atau lebar terminal,  `rows=$(tput lines)` untuk mengambil jumlah baris atau tinggi terminal, dan `declare -A positions` untuk mendeklarasikan array `positions`

```sh
for ((i = 0; i < cols; i++)); do
        positions[$i]=$((RANDOM % rows))
    done
```
loop ini mengisi `positions[$i]` dengan posisi acak dalam baris terminal untuk setiap kolom

```sh
for ((i = 0; i < cols / 2; i++)); do
            col=$((RANDOM % cols))
```
loop ini memilih setengah dari total kolom terminal untuk menampilkan simbol didalamnya terdapat `col` untuk menyimpan kolom acak untuk menampilkan simbol 

```sh
symbol="${symbols[RANDOM % ${#symbols[@]}]}"
            color="${colors[RANDOM % ${#colors[@]}]}"
```
`symbol` untuk memilih mata uang acak dari array `symbols` dan `color` untuk memilih warna acak dari array `colors`

```sh
tput cup "${positions[$col]}" "$col"
            echo " "
```
`tput cup x y` untuk memindahkan kursor ke posisi sebelumnya dan `echo " "` berguna untuk menghapus simbol sebelumnya dengan mencetak spasi

```sh
new_pos=$((positions[$col] - 2))
            if (( new_pos < 0 )); then new_pos=$rows; fi
            positions[$col]=$new_pos
```
Menghitung posisi baru dengan mengurangi 2 baris. Jika posisi baru kurang dari 0, maka diatur ulang ke baris paling bawah

```sh
tput setaf $color
            if (( RANDOM % 10 < 3 )); then
                tput bold
            fi
```
`tput setaf $color` untuk mengatur warna teks, 30% kemungkinan `( RANDOM % 10 < 3)` akan membuat simbol ditampilkan dalam teks tebal `tput bold`

```sh
tput cup "$new_pos" "$col"
            echo -n "$symbol"
```
memindahkan kursor ke posisi baru `$new_pos` dan `$col` lalu mencetak `$symbol` tanpa newline

7. Fungsi `brain_damage` menampilkan proses yang sedang berjalan, seperti task manager yang dapat menampilkan data baru setiap detiknya
```sh
brain_damage(){
    RESET='\033[0m'
    BOLD='\033[1m'
    PINK='\033[38;5;218m'
    BLUE='\033[38;5;117m'
    GREEN='\033[38;5;120m'
    YELLOW='\033[38;5;221m'
    PURPLE='\033[38;5;183m'
    WHITE='\033[1;37m'
    COLORS=("$PINK" "$BLUE" "$GREEN" "$YELLOW" "$PURPLE")
    clear
    tput civis
    stty -echo # Matikan echo agar terminal tetap rapi
    trap "tput cnorm; stty echo; exit" SIGINT  # Tampilkan kursor & kembalikan terminal saat keluar

    while true; do
        tput cup 0 0
        top_output=$(top -b -n 1 | head -n 22)

        IFS=$'\n' read -rd '' -a lines <<<"$top_output"

        for i in "${!lines[@]}"; do
            COLOR="${COLORS[$((i % ${#COLORS[@]}))]}"

            if [ $i -lt 5 ]; then
                echo -e "${BOLD}${COLOR}${lines[$i]}${RESET}"

            elif [ $i -eq 5 ]; then
                echo -e "${WHITE}${BOLD}${lines[$i]}${RESET}"

            else
                echo -e "${COLOR}${lines[$i]}${RESET}"
            fi

            if [[ $i -eq 4 ]]; then
                echo ""
            fi
        done

        sleep 1
    done
    tput cnorm
    stty echo # Aktifkan kembali input terminal
}
```
- `trap "tput cnorm; stty echo; exit" SIGINT` menangani CTRL+C untuk mengembalikan terminal ke keadaan semula
- Menggunakan `top -b -n 1 | head -n 22` untuk mendapatkan snapshot pertama dari proses yang berjalan
- Memisahkan output `top` menjadi array `lines` berdasarkan newline `(IFS=$'\n')`
- Mengiterasi setiap baris dalam `lines` dan menerapkan warna berdasarkan indeksnya
- Jika indeks `i < 5`, teks dicetak dengan warna tebal
- Jika `i == 5`, teks menggunakan warna putih tebal
- Berjalan tanpa henti, memperbarui output top setiap detik `sleep 1`
- Setelah keluar, kursor dikembalikan `tput cnorm` dan terminal dinormalisasi `stty echo`

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
