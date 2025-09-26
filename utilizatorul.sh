#!/bin/bash
utilizatori=("$1")
utilizatori_online() {
        echo "---*Utilizatori online*---"
        if [ ${#utilizatori[@]} -eq 0 ]; then
                echo "Nu este niciun barbat online in acest moment din zi"
        else
                for user in "${utilizatori[@]}"; do
                        echo "$user"
                done
        fi
}


while true; do
    echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    echo "1) Afișează utilizatori activi"
    echo "2) Logout"
    echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    read -p "Alege o opțiune: " opt
    case $opt in
        1) utilizatori_online ;;
        2) echo "Delogare cu succes"; exit 0 ;;
        *) echo "Opțiune invalidă." ;;
    esac
done
