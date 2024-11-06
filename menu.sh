#!/bin/bash

# SCRIPT 1
# LIST USERS
function listar_usuarios {
    cut -d: -f1 /etc/passwd
}

# SCRIPT 2
# CAMBIO DE PASSWORD
function cambiar_contrasena {
    read -p "Introduce el nombre de usuario: " username
    read -s -p "Introduce la nueva contraseña: " password
    echo
    echo "$username:$password" | sudo chpasswd
    echo "Contraseña de $username cambiada exitosamente."
}

# SCRIPT 3
# DROP USER
function eliminar_usuario {
    read -p "Introduce el nombre de usuario: " username
    sudo deluser --remove-home $username
    echo "Usuario $username eliminado exitosamente."
}

# SCRIPT 4
# NEW USER
function crear_usuario {
    read -p "Introduce el nombre de usuario: " username
    read -s -p "Introduce la contraseña: " password
    echo
    sudo useradd -m $username
    echo "$username:$password" | sudo chpasswd
    sudo usermod -aG sudo $username
    echo "Usuario $username creado exitosamente."
}

# MENÚ PRINCIPAL
function mostrar_menu {
    echo "====================="
    echo " MENÚ PRINCIPAL"
    echo "====================="
    echo "1. Listar Usuarios"
    echo "2. Cambiar Contraseña"
    echo "3. Eliminar Usuario"
    echo "4. Crear Usuario"
    echo "====================="
    echo "0. Salir"
    echo "====================="
}

function procesar_opcion {
    case $1 in
        1) listar_usuarios ;;
        2) cambiar_contrasena ;;
        3) eliminar_usuario ;;
        4) crear_usuario ;;
        0) echo "Saliendo del programa..."; exit 0 ;;
        *) echo "Opción no válida. Inténtalo de nuevo." ;;
    esac
}

while true; do
    mostrar_menu
    read -p "Selecciona una opción: " opcion
    procesar_opcion $opcion
done
