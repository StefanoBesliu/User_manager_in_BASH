#!/bin/bash
cale_actuala=$(pwd)
count_file=$(find  -type f | wc -l)
count_dir=$(find   -type d | wc -l)
cale_fisier=()
fisier=()
spatiu_ocupat=()
spatiu_total=$( echo "$(du -h . )" | tail -1 | sed 's/\([0-9\.*a-zA-Z]*\).*/\1/' )
cd ..
cale_parinte=$(pwd)
printf "" > "provizoriu.txt"
cd "$cale_actuala"
find  -type f,d -exec echo {} >> "${cale_parinte}/provizoriu.txt" \;
mapfile -t cale_fisier < "${cale_parinte}/provizoriu.txt"
for (( i=1; i<${#cale_fisier[@]}; i++ )); do
        cale_fisier[i]=$( du -h "${cale_fisier[i]}" )
        #echo "${fisier[i]}"
        test=$(echo "${cale_fisier[i]}" | grep -i "^0")
        if [[ -z "$test" ]]; then
                spatiu_ocupat[i-1]=$(echo "${cale_fisier[i]}" | sed 's/\([0-9\.]*[^ ]\{1\}\).*/\1/')
                cale_fisier[i]=$(echo "${cale_fisier[i]}" | sed 's/\([^a-zA-Z]*\)\([a-zA-Z]\{1\}\)\([^a-zA-Z0-9]*\)\([a-zA-Z0-9]*\)/\4/')
        else
                spatiu_ocupat[i-1]="0K"
                cale_fisier[i]=$(echo "${cale_fisier[i]}" | sed 's/\([^a-zA-Z0-9]*\)\([a-zA-Z0-9]*\)/\2/')
        fi
        #cale_fisier[i]=$(echo "${cale_fisier[i]}" | sed 's/\([^a-zA-Z]*\)\([a-zA-Z]\{1\}\)\([^a-zA-Z]*\)\([a-zA-Z]*\)/\4/')
        fisier[i]=$(echo "${cale_fisier[i]}" | sed 's/\([^\/]*\)\/\(.*\)/\2/')
done
rm "${cale_parinte}/provizoriu.txt"
#echo "${cale_fisier[@]}"
#echo "${fisier[@]}"
raport="raport_$1.txt"
touch "$raport"
echo "Directoare totale: $count_dir" > "$raport"
echo "Fisiere totale: $count_file" >> "$raport"
echo "Pentru directorul $1, al utilizatorului $1, avem in total ${spatiu_total} ocupati:" >> "$raport"
exista_director=0
exista_fisier=0
echo "Directoare:" >> "$raport"
for (( i=1; i<${#cale_fisier[@]}; i++ )); do
        if [[ -d "$(pwd)/${cale_fisier[i]}" ]]; then
                exista_director=1
                echo "${fisier[i]}      ${spatiu_ocupat[i-1]}" >> "$raport"
        fi
done
if [ $exista_director -eq 0 ]; then
        echo "Nu exista directoare!" >> "$raport"
else
        echo "------------------------------------------------------" >> "$raport"
fi
echo "Fisiere:" >> "$raport"
for (( i=1; i<${#cale_fisier[@]}; i++ )); do
        if [[ -f "$(pwd)/${cale_fisier[i]}" || ! -s "$(pwd)/${cale_fisier[i]}" ]]; then
                exista_fisier=1
                echo "${fisier[i]}      ${spatiu_ocupat[i-1]}" >> "$raport"
        fi
done
if [ $exista_fisier -eq 0 ]; then
        echo "Nu exista fisiere!" >> "$raport"
else
        echo "-------------------------------------------------------" >> "$raport"
fi
#echo ""
#for (( i=1; i<${#cale_fisier[@]}; i++ )); do
#       printf "${fisier[i]} "
#       echo "${spatiu_ocupat[i-1]}"
#done
