#!/bin/bash

# Comprovar si som root
# Verifica si l'script s'executa amb permisos de root. $UID guarda l'ID de l'usuari executant.
# Si no és root (normalment ID 0), mostra un missatge d'error i surt de l'script.
if [[ $UID -ne 0 ]]; then
    echo "Aquest script s'ha d'executar com a root." >&2
    exit 1
fi

# Desactivar interrupcions amb CTRL+C
# Això evita que l'usuari pugui interrompre l'script amb la combinació de tecles CTRL+C.
trap '' SIGINT

# Maneig d'errors generals
# Cada cop que un comandament falla, mostra un missatge d'error i surt de l'script.
trap 'echo "Error: una acció ha fallat."; exit 1' ERR

# Funció per aplicar colors i estils
# Afegeix colors i estils visuals al terminal per fer l'script més atractiu visualment.
# Això es fa amb 'tput', que controla atributs com colors, text en negreta i fons.
tput_clear() { tput clear; }       # Neteja la pantalla
tput_color() { tput setaf "$1"; }   # Aplica un color de text (paràmetre $1)
tput_bold() { tput bold; }          # Aplica negreta
tput_bg() { tput setab "$1"; }      # Aplica un color de fons (paràmetre $1)
tput_reset() { tput sgr0; }         # Restableix els estils

# Funció de barra de progrés simple
# Mostra una barra de progrés per indicar visualment el progrés d'una tasca.
barra_progres() {
    echo -n "["                       # Inicia la barra amb "["
    for ((i = 0; i < 50; i++)); do    # Bucle per afegir 50 "##" a la barra
        echo -n "#"
        sleep 0.02                    # Pausa breu per cada increment per simular progrés
    done
    echo "]"                          # Finalitza la barra amb "]"
}

# Funció per mostrar el menú amb estil
# Mostra el menú principal amb estils i colors.
menu_principal() {
    tput_clear
    tput_bold
    tput_color 3
    echo "=================================="
    echo "   BENVINGUT AL ESCRIPTAZO"
    echo "=================================="
    tput_color 6
    echo "1. Gestió d'usuaris"
    echo "2. Còpies de seguretat"
    echo "3. Gestió de processos"
    echo "4. Sortir"
    tput_color 2
    echo -n "Escull una opció: "
    tput_reset
}

# Funció per registrar activitats
# Aquesta funció guarda els esdeveniments importants en un fitxer de registre i en el sistema.
registre() {
    logger "$1"                           # Guarda l'esdeveniment en el registre del sistema
    echo "$1" >> /var/log/gestio_sistema.log  # Afegeix l'esdeveniment al fitxer de registre personalitzat
}

# Funció de gestió d'usuaris
# Aquesta funció permet gestionar usuaris del sistema amb tres opcions:
# 1) Crear, 2) Eliminar, i 3) Modificar usuaris, o "Tornar" al menú principal.
gestio_usuaris() {
    tput_color 6
    echo "Opcions de gestió d'usuaris:"
    select opt in "Alta" "Baixa" "Modificació" "Tornar"; do
        case $opt in
            "Alta")
                echo "Introdueix el nom d'usuari a crear:"  # Llegeix el nom del nou usuari
                read usuari
                useradd "$usuari" && echo "Usuari $usuari creat correctament."  # Crea l'usuari
                registre "Usuari $usuari creat correctament."
                ;;
            "Baixa")
                echo "Introdueix el nom d'usuari a eliminar:"  # Llegeix el nom de l'usuari a eliminar
                read usuari
                userdel "$usuari" && echo "Usuari $usuari eliminat correctament."
                registre "Usuari $usuari eliminat correctament."
                ;;
            "Modificació")
                echo "Introdueix el nom d'usuari per modificar:"  # Llegeix el nom de l'usuari a modificar
                read usuari
                echo "Quin grup vols afegir l'usuari $usuari?"  # Demana el grup nou per l'usuari
                read grup
                usermod -aG "$grup" "$usuari" && echo "Usuari $usuari afegit al grup $grup correctament."
                registre "Usuari $usuari afegit al grup $grup."
                ;;
            "Tornar")
                return
                ;;
            *)
                echo "Opció no vàlida"
                ;;
        esac
    done
    echo "Retornant al menú principal..."
}

# Funció de còpies de seguretat amb barra de progrés
# Permet fer còpies de seguretat amb opció d'encriptar-les.
copia_segur() {
    echo "Introdueix el directori d'origen:"  # Llegeix el directori d'origen de les dades
    read origen
    echo "Introdueix el directori de destinació:"  # Llegeix el directori de destinació
    read desti

    echo "Vols encriptar la còpia de seguretat? (s/n)"  # Opció per encriptar
    read encriptar

    if [[ $encriptar == "s" ]]; then
        echo "Introdueix una contrasenya per encriptar la còpia:"  # Demana contrasenya per encriptar
        read -s password
        rsync -av --progress "$origen" "$desti" && \
        tar czf - "$desti" | openssl enc -aes-256-cbc -salt -out "$desti".tar.gz.enc -pass pass:"$password" && \
        echo -n "Encriptant còpia "
        barra_progres
        echo "Còpia de seguretat encriptada completada correctament."
        registre "Còpia de seguretat encriptada de $origen a $desti realitzada correctament."
    else
        rsync -av --progress "$origen" "$desti" && echo -n "Còpia de seguretat en curs "
        barra_progres
        echo "Còpia de seguretat completada correctament."
        registre "Còpia de seguretat de $origen a $desti realitzada correctament."
    fi
    echo "Retornant al menú principal..."
}

# Funció de gestió de processos millorada
# Permet buscar, consultar, i canviar la prioritat dels processos.
gestio_processos() {
    echo "Opcions de gestió de processos:"
    select opt in "Buscar per nom" "Buscar per PID" "Canviar prioritat" "Veure detalls" "Tornar"; do
        case $opt in
            "Buscar per nom")
                echo "Introdueix el nom del procés:"  # Llegeix el nom del procés a buscar
                read nom_proces
                pgrep "$nom_proces" || echo "No s'ha trobat cap procés amb aquest nom."
                registre "Cerca de processos amb el nom $nom_proces."
                ;;
            "Buscar per PID")
                echo "Introdueix el PID del procés:"  # Llegeix el PID del procés a buscar
                read pid
                ps -p "$pid" -o pid,comm,%mem,%cpu,stat || echo "No s'ha trobat cap procés amb aquest PID."
                registre "Cerca del procés amb PID $pid."
                ;;
            "Canviar prioritat")
                echo "Introdueix el PID del procés:"  # Llegeix el PID del procés per canviar prioritat
                read pid
                echo "Introdueix la nova prioritat (de -20 a 19):"  # Demana la nova prioritat
                read nova_prioritat
                renice "$nova_prioritat" -p "$pid" && echo -n "Canviant prioritat "
                barra_progres
                echo "Prioritat canviada correctament."
                registre "Prioritat del procés $pid canviada a $nova_prioritat."
                ;;
            "Veure detalls")
                echo "Introdueix el PID del procés a veure:"  # Llegeix el PID per veure'n els detalls
                read pid
                ps -p "$pid" -o pid,comm,%mem,%cpu,stat,start_time || echo "No s'ha trobat cap procés amb aquest PID."
                registre "Detalls del procés $pid consultats."
                ;;
            "Tornar")
                return
                ;;
            *)
                echo "Opció no vàlida"
                ;;
        esac
    done
    echo "Retornant al menú principal..."
}

# Menú principal
# Mostra el menú principal repetidament fins que l'usuari triï l'opció de sortir.
while true; do
    menu_principal
    read opcio
    case $opcio in
        1)
            gestio_usuaris  # Executa la funció de gestió d'usuaris
            ;;
        2)
            copia_segur  # Executa la funció de còpies de seguretat
            ;;
        3)
            gestio_processos  # Executa la funció de gestió de processos
            ;;
        4)
            echo "Sortint..."  # Missatge de sortida
            registre "Sortida de l'script."  # Registra la sortida
            exit 0  # Surt de l'script
            ;;
        *)
            echo "Opció no vàlida"
            ;;
    esac
done

