#!/bin/bash

# Nama file dataset
DATA_FILE="reading_data.csv"

# Periksa apakah file ada
if [[ ! -f "$DATA_FILE" ]]; then
    echo "File $DATA_FILE tidak ditemukan. Pastikan file ada di direktori yang sama."
    exit 1
fi

# Menampilkan menu pilihan
echo "Pilih opsi:"
echo "1. Hitung jumlah buku yang dibaca Chris Hemsworth"
echo "2. Hitung rata-rata durasi membaca dengan Tablet"
echo "3. Temukan pembaca dengan rating tertinggi"
echo "4. Cari genre paling populer di Asia setelah 2023"
read -p "Masukkan pilihan (1-4): " pilihan

# pilihan 1
if [[ "$pilihan" -eq 1 ]]; then
    jumlah=$(awk -F',' 'NR>1 && $2 ~ /Chris Hemsworth/ {count++} END {print (count ? count : 0)}' "$DATA_FILE")
    echo "Chris Hemsworth membaca" $jumlah "buku."

elif [[ "$pilihan" -eq 2 ]]; then
    rata_rata=$(awk -F',' 'NR>1 && $8 ~ /Tablet/ {sum += $6; count++} 
        END {if (count > 0) print sum / count; else print "0"}' "$DATA_FILE")
    echo "Rata-rata durasi membaca dengan Tablet adalah" $rata_rata "menit."

elif [[ "$pilihan" -eq 3 ]]; then
    hasil=$(awk -F',' 'NR > 1 {if ($7 > max) {max=$7; name=$2; title=$3}} 
        END {print name, title, max}' "$DATA_FILE")

    nama=$(echo "$hasil" | awk '{print $1}')
    judul=$(echo "$hasil" | awk '{$1=""; $NF=""; print $0}' | sed 's/^ *//')
    rating=$(echo "$hasil" | awk '{print $NF}')

    echo "Pembaca dengan rating tertinggi: $nama - $judul - $rating"

elif [[ "$pilihan" -eq 4 ]]; then
    hasil=$(awk -F',' 'NR>1 && $5 > "2023-12-31" && $9 ~ /Asia/ {genre_count[$4]++} 
        END {
            max=0; 
            for (g in genre_count) 
                if (genre_count[g] > max) { 
                    max=genre_count[g]; 
                    popular=g;
                } 
            print popular, max
        }' "$DATA_FILE")

    genre=$(echo "$hasil" | awk '{print $1}')
    jumlah=$(echo "$hasil" | awk '{print $2}')
    
    echo "Genre paling populer di Asia setelah 2023 adalah $genre dengan $jumlah buku."
fi



