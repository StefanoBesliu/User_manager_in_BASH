#!/bin/bash
#sudo apt install mailutils
source activi.sh
locatie="$(pwd)"
toti_utilizatorii() {
        local gasit=$(sed 's/^\([^,]*,\) \([^,]*\).*/\2/' "database.csv")
        if [[ -n "$gasit" ]]; then
                printf "Utilizatorii inregistrati sunt: "
                echo "$gasit"
                echo ""
        else
                echo "Nu exista barbati inregistrati"
        fi
}
generare_raport1() {
  printf "Introdu numele utilizatorului caruia doresti sa afli raportul: "
  local nume_utilizator
  read nume_utilizator
  local exista
  exista=$(grep -w "${nume_utilizator}" "database.csv")
  if [ -n "$exista" ]; then
        #copie_nume="${nume_utilizator}"
        local parola_utilizator
        printf "Introdu parola: "
        parola_utilizator=$(citire_silentioasa)
        local parola_criptata
        parola_criptata=$(echo "${parola_utilizator}" | sha256sum)
        local parola_criptata_din_baza
        parola_criptata_din_baza=$(echo "${exista}" | sed 's/\(\([^,]*,\)\{2\}\) \([^,]*\).*/\3/')
        local greseli=1
        while [[ "$parola_criptata_din_baza" != "$parola_criptata" && $greseli -lt 3 ]] do
                printf "Parola gresita!\nMai aveti $((3 - greseli)) incercari: "
                greseli=$(($greseli + 1))
                parola_utilizator=$(citire_silentioasa)
                parola_criptata=$(echo "${parola_utilizator}" | sha256sum)
        done
        if [ $greseli -eq 3 ]; then
                printf "Ai atins numarul maxim de greseli!\n"
                return 1
        fi
        cd "$nume_utilizator"
        bash $locatie/copie_du.sh "$nume_utilizator"
        echo ""
        cat "raport_${nume_utilizator}.txt"
        echo ""
        cd "$locatie"
  else
        echo "Nu exista utilizatorul!"
  fi

}
generare_raport() {
        printf "Introdu numele utilizatorului caruia doresti sa afli raportul: "
        local nume_utilizator
        read nume_utilizator
        local exista=$(find "$locatie" -type d -name "$nume_utilizator")
        if [[ -z "$exista" ]]; then
                echo "Utilizatorul nu exista!"
                return 1
        fi
        cd "$nume_utilizator"
        bash $locatie/copie_du.sh "$nume_utilizator"
        echo ""
        cat "raport_${nume_utilizator}.txt"
        echo ""
        cd "$locatie"
}
activitate_utilizator() {
        cd "$1"
        ((nr_activi++))
        utilizatori[nr_activi]="$1"
        #utilizatori+=("$1")
        printf "Poti folosi orice comanda!\nPentru a accesa meniul, scrie meniu!\n"
        dir_curent=$(pwd)
        printf "${copie_nume}@stud1014:${dir_curent}\$"
        read input
        while [[ "$input" != "meniu" ]]; do
                eval "${input}"
                dir_curent=$(pwd)
                printf "$1@stud1014:${dir_curent}\$"
                read input
        done
        bash $locatie/copie_du.sh "$1" &
        cd "$locatie"
        bash utilizatorul.sh "${utilizatori[@]}" "$nr_activi"
        nr_activi=$((nr_activi - 1))
}
generator_id(){
local nume="$1"
local vector=()
for (( i=0; i<${#nume}; i++ )); do
        local aux=${nume:$i:1}
        vector[i]=$(printf "%d" "'$aux")
done
for (( i=1; i<${#vector[0]}; i++ )); do
        vector[0]="${vector[0]}${vector[i]}"
done
echo "${vector[0]}"
}
generator_string() {
local sir=('a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 'u' 'v' 'w' 'x' 'y' 'z' '1' '2' '3' '4' '5' '6' '7' '8' '9' '0')
local string=()
local nr_aleatoriu=$RANDOM
local iteratii=$((nr_aleatoriu % 10 + 4))
for (( i=0; i<$iteratii; i++ )); do
        local indice=$(($RANDOM % 36))
        string[i]="${sir[indice]}"
done
for (( i=1; i<${#string[@]}; i++ )); do
        string[0]="${string[0]}${string[i]}"
done
echo "${string[0]}"
}
citire_silentioasa() {
  local vector=()
  local i=0
  local enter=$(echo "")
  read -sn1 vector[i]
  while [[ ${vector[i]} != $enter ]]; do
        printf "*" >&2
        ((i++))
        read -sn1 vector[i]
  done
  for (( i=1; i<${#vector[@]}; i++ )) do
        vector[0]="${vector[0]}${vector[i]}"
  done
  printf "\n" >&2
  echo "${vector[0]}"
}
inregistrare_utilizator() {
  cd "$locatie"
  local nume_utilizator
  printf "Introdu numele de utilizator aferent noului user: "
  read nume_utilizator
  exista_utilizator=$(grep -w "$nume_utilizator" "database.csv")
  if [ -n "${exista_utilizator}" ]; then
        printf "Utilizatorul ${nume_utilizator} exista deja!\n"
        return 1
  else
        printf "Utilizatorul ${nume_utilizator} nu exista, il creeam!\n"
        local parola_utilizator
        printf "Reintrodu parola: "
        copie_parola=$(citire_silentioasa)
        while [[ "$parola_utilizator" != "$copie_parola" ]] do
                printf "Parola gresita!\n"
                printf "Reintrodu parola sau intoarce-te la meniu tastand 'B': "
                copie_parola=$(citire_silentioasa)
                if [[ "$copie_parola" = 'B' ]]; then
                        return 1
                fi
        done
        parola_criptata=$(echo "${parola_utilizator}" | sha256sum)
        printf "Introdu adresa de email a utilizatorului: "
        local email_utilizator
        read email_utilizator
        local data
        data=$(date)
        local id=$(generator_id "$nume_utilizator")
        echo "${id}, ${nume_utilizator}, ${parola_criptata}, ${email_utilizator}, ${data}" >> database.csv
        printf "Utilizatorul a fost creeat cu succes!\n"
        #Apel functie trimitere mail;
        bash trimitere_mail.sh "${email_utilizator}"
        #echo "Salut, contul de utilizator ${nume_utilizator} a fost creeat cu succes!" | mail -s "Felicitari!" "stud1014@sop.ase.ro"
        mkdir "${nume_utilizator}"
        #utilizatori+=("$nume_utilizator")
        activitate_utilizator "$nume_utilizator"
  fi
}
logare() {
  cd "$locatie"
  local nume_utilizator
  printf "Introdu numele de utilizator aferent contului pe care doresti sa-l accesezi: "
  read nume_utilizator
  local exista
  exista=$(grep -w "${nume_utilizator}" "database.csv")
  if [ -n "$exista" ]; then
        #copie_nume=$(nume_utilizator)
        local parola_utilizator
        printf "Introdu parola: "
        parola_utilizator=$(citire_silentioasa)
        local parola_criptata
        parola_criptata=$(echo "${parola_utilizator}" | sha256sum)
        local parola_criptata_din_baza
        parola_criptata_din_baza=$(echo "${exista}" | sed 's/\(\([^,]*,\)\{2\}\) \([^,]*\).*/\3/')
        local greseli=1
        while [[ "$parola_criptata_din_baza" != "$parola_criptata" && $greseli -lt 3 ]] do
                printf "Parola gresita!\nMai aveti $((3 - greseli)) incercari: "
                greseli=$(($greseli + 1))
                parola_utilizator=$(citire_silentioasa)
                parola_criptata=$(echo "${parola_utilizator}" | sha256sum)
        done
        if [ $greseli -eq 3 ]; then
                printf "Ai atins numarul maxim de greseli!\n"
                return 1
        fi
        printf "Logat cu succes!\n"
        local data
        data=$(date)
        sed -i "${numar_linie}s/\(\([^,]*,\)\{4\}\).*/\1 ${data}/" database.csv
        #utilizatori+=("$nume_utilizator")
        activitate_utilizator "$nume_utilizator"
  else
        printf "Utilizatorul nu exista!\n"
  fi
}
stergere_utilizator() {
        cd "$locatie"
        printf "Introdu numele utilizatorului pe care doresti sa-l stergi: "
        local nume_utilizator
        read nume_utilizator
        local gasit=$(grep -w "$nume_utilizator" "database.csv")
        if [[ -n "$gasit"  ]]; then
                printf "Introdu parola: "
                local parola_utilizator
                parola_utilizator=$(citire_silentioasa)
                local parola_criptata=$(echo "$parola_utilizator" | sha256sum)
                local parola_criptata_din_baza=$(echo "$gasit" | sed 's/\(\([^,]*,\)\{2\}\) \([^,]*\).*/\3/')
                if [[ "$parola_criptata_din_baza" = "$parola_criptata" ]]; then
                        printf "Pentru a confirma stergerea decisiva a utilizatorului, introduceti cheia afisata: "
                        local cheie="$(generator_string)"
                        printf "$cheie\n"
                        local cheie_introdusa
                        read cheie_introdusa
                        if [[ "$cheie_introdusa" = "$cheie" ]]; then
                                printf "Cont sters!\n"
                                rm -r "$nume_utilizator"
                                local loc_in_baza=$(grep -wn "$nume_utilizator" "database.csv")
                                local numar_linie=$(echo "$loc_in_baza" | sed 's/\([0-9]*\).*/\1/')
                                sed -i "${numar_linie}d" "database.csv"
                        else
                                printf "Cheie gresita! Reintrodu sau anuleaza procesul apasand tasta B: "
                                read cheie_introdusa
                                if [[ "$cheie_introdusa" = "B" ]]; then
                                        printf "Anulat cu succes!\n"
                                        return 1
                                fi
                                while [[ "$cheie_introdusa" != "$cheie" ]]; do
                                        printf "Cheie gresita! Reintrodu sau anuleaza procesul apasand tasta B: "
                                        read cheie_introdusa
                                        if [[ "$cheie_introdusa" = "B" ]]; then
                                                printf "Anulat cu succes!\n"
                                                return 1
                                        fi
                                done
                                printf "Cont sters!\n"
                                rm -r "$nume_utilizator"
                                local loc_in_baza=$(grep -wn "$nume_utilizator" "database.csv")
                                local numar_linie=$(echo "$loc_in_baza" | sed 's/\([0-9]*\).*/\1/')
                                sed -i "${numar_linie}d" "database.csv"
                        fi
                else
                        printf "Parola gresita!\n"
                fi
        else
                printf "Utilizatorul nu exista!\n"
        fi
}

utilizatori_online() {
    if [ $nr_activi -eq 0 ]; then
        echo "Nu este niciun barbat online in acest moment din zi"
    else
        echo "---*Utilizatori online*---"
        for (( i=0; i<$nr_activi; i++ )); do
                echo "${utilizatori[i]}"
        done
        echo "Numarul total de utilizatori online este: $nr_activi"
   fi
}
while true; do
    echo "----------------------------"
    echo "1.Inregistreaza un nou utilizator"
    echo "2.Logheaza-te"
    echo "3.Generează raport"
    echo "4.Sterge utilizator"
    echo "5.Utilizatorii activi in acest moment"
    echo "6.Utilizatorii inregistrati"
    echo "7.Iesire"
    echo "----------------------------"
    read -p "Alege o opțiune: " opt

    case $opt in
        1) inregistrare_utilizator ;;
        2) logare ;;
        3) generare_raport1 ;;
        4) stergere_utilizator ;;
        5) utilizatori_online ;;
        6) toti_utilizatorii ;;
        7) echo "Iesire efectuata cu succes"; exit 0 ;;
        *) echo "Opțiune nevalidă." ;;
    esac
done


