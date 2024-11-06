#!/bin/bash

# Función para pausar el flujo y esperar que el usuario presione enter
pausa() {
    read -p "Presiona Enter para continuar..."
}

# Función para listar todos los usuarios del sistema
listar_usuarios() {
    echo "Usuarios registrados en el sistema:"
    cut -d: -f1 /etc/passwd
    pausa
}

# Función para agregar un nuevo usuario al sistema
agregar_usuario() {
    read -p "Ingresa el nombre del nuevo usuario: " nuevo_usuario
    
    if id "$nuevo_usuario" &>/dev/null; then
        echo "El usuario '$nuevo_usuario' ya existe."
    else
        sudo useradd "$nuevo_usuario"
        if [ $? -eq 0 ]; then
            echo "Usuario '$nuevo_usuario' creado exitosamente."
        else
            echo "Hubo un error al crear el usuario."
        fi
    fi
    pausa
}

# Función para buscar archivos por propietario
buscar_archivos_por_usuario() {
    read -p "Ingresa el nombre del usuario para buscar sus archivos: " nombre_usuario
    
    if id "$nombre_usuario" &>/dev/null; then
        echo "Buscando archivos propiedad de '$nombre_usuario'..."
        sudo find / -user "$nombre_usuario" 2>/dev/null
    else
        echo "El usuario '$nombre_usuario' no existe."
    fi
    pausa
}

# Función para gestionar permisos de un archivo
gestionar_permisos_archivo() {
    read -p "Ingresa la ruta del archivo a modificar permisos: " ruta_archivo
    
    if [ -f "$ruta_archivo" ]; then
        echo "Permisos actuales del archivo:"
        ls -l "$ruta_archivo"
        
        read -p "Ingresa los permisos nuevos (ejemplo: 755): " nuevos_permisos
        sudo chmod "$nuevos_permisos" "$ruta_archivo"
        
        if [ $? -eq 0 ]; then
            echo "Permisos modificados exitosamente."
        else
            echo "Hubo un error al modificar los permisos."
        fi
    else
        echo "El archivo '$ruta_archivo' no existe."
    fi
    pausa
}

# Función para eliminar un usuario del sistema
eliminar_usuario() {
    read -p "Ingresa el nombre del usuario a eliminar: " usuario_eliminar

    if id "$usuario_eliminar" &>/dev/null; then
        read -p "¿Estás seguro que deseas eliminar al usuario '$usuario_eliminar'? (s/n): " confirmacion
        
        if [ "$confirmacion" == "s" ]; then
            sudo userdel -r "$usuario_eliminar"
            if [ $? -eq 0 ]; then
                echo "Usuario '$usuario_eliminar' eliminado exitosamente."
            else
                echo "Hubo un error al eliminar el usuario."
            fi
        else
            echo "Operación cancelada."
        fi
    else
        echo "El usuario '$usuario_eliminar' no existe."
    fi
    pausa
}

# Función para mostrar el menú
menu_principal() {
    echo "=========================="
    echo "  Menú de Gestión Avanzada"
    echo "=========================="
    echo "1. Listar usuarios del sistema"
    echo "2. Agregar un nuevo usuario"
    echo "3. Buscar archivos por propietario"
    echo "4. Gestionar permisos de un archivo"
    echo "5. Eliminar un usuario del sistema"
    echo "6. Salir"
    echo "=========================="
}

# Función principal que controla el flujo del programa
ejecutar_menu() {
    opcion=0
    until [ "$opcion" -eq 6 ]; do
        menu_principal
        read -p "Elige una opción [1-6]: " opcion
        
        case $opcion in
            1)
                listar_usuarios
                ;;
            2)
                agregar_usuario
                ;;
            3)
                buscar_archivos_por_usuario
                ;;
            4)
                gestionar_permisos_archivo
                ;;
            5)
                eliminar_usuario
                ;;
            6)
                echo "Saliendo del programa..."
                ;;
            *)
                echo "Opción no válida. Inténtalo de nuevo."
                pausa
                ;;
        esac
    done
}

# Iniciar el programa
ejecutar_menu
