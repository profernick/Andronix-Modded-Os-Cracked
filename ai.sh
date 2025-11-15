#!/bin/bash

PS3="Select Number (1-5): "

options=("Manjaro xfce" "Ubuntu xfce" "Debian xfce" "Ubuntu kde" "Exit)

echo ""\033[0;32m Andronix Modded Os Crack!!! Fuck Andronix \033[0m"
echo "Please Select Distribution to install:"

select opt in "${options[@]}"
do
    case $opt in
        "Manjaro xfce")
            echo "Selected installation: Manjaro xfce..."
            bash <(curl -s https://raw.githubusercontent.com/profernick/Andronix-Modded-Os-Cracked/refs/heads/main/nahuy.sh)
            break
            ;;
        "Ubuntu xfce")
            echo "Selected Instalation: Ubuntu xfce..."
            bash <(curl -s https://raw.githubusercontent.com/profernick/Andronix-Modded-Os-Cracked/refs/heads/main/nahuy2.sh)
            break
            ;;
        "Debian xfce")
            echo "Выбрана установка Debian xfce..."
            bash <(curl -s https://raw.githubusercontent.com/profernick/Andronix-Modded-Os-Cracked/refs/heads/main/nahuy3.sh)
            break
            ;;
        "Ubuntu kde")
            echo "Selected installation: Ubuntu kde..."
            bash <(curl -s https://raw.githubusercontent.com/profernick/Andronix-Modded-Os-Cracked/refs/heads/main/nahuy4.sh)
            break
            ;;
        "Exit")
            echo "Cancel..."
            break
            ;;
        *) 
            echo "Incorrect Number"
            ;;
    esac
done
