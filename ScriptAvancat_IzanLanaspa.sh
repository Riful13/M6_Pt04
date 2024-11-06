#!/bin/bash

# Desactivar CTRL + C
trap "" SIGINT

# Directorio para organizar (por defecto el actual)
DIRECTORIO="${1:-$(pwd)}"

# Subcarpetas para cada tipo de archivo
declare -A CARPETAS=( ["Imágenes"]="Imágenes" ["Documentos"]="Documentos" ["Videos"]="Videos" ["Audios"]="Audios" ["Otros"]="Otros" )

# Crear las carpetas necesarias en el directorio indicado
crear_carpetas() {
    for carpeta in "${CARPETAS[@]}"; do
        mkdir -p "$DIRECTORIO/$carpeta"
    done
    echo "Carpetas creadas en $DIRECTORIO"
}

# Función para mover archivos a cada carpeta según sus extensiones
mover_archivo() {
    local archivo="$1"
    local destino="$2"

    if [ -e "$destino/$(basename "$archivo")" ]; then
        local base=$(basename "$archivo")
        local nombre="${base%.*}"
        local extension="${base##*.}"
        local i=1
        while [ -e "$destino/$nombre($i).$extension" ]; do
            ((i++))
        done
        mv "$archivo" "$destino/$nombre($i).$extension"
    else
        mv "$archivo" "$destino/"
    fi
}

# Clasificar y mover archivos
clasificar_archivos() {
    echo "Clasificando archivos en $DIRECTORIO..."
    for archivo in "$DIRECTORIO"/*; do
        if [ -f "$archivo" ]; then
            case "${archivo,,}" in
                *.jpg|*.jpeg|*.png|*.gif|*.webp|*.bmp|*.tiff) mover_archivo "$archivo" "$DIRECTORIO/${CARPETAS[Imágenes]}" ;;
                *.pdf|*.doc|*.docx|*.txt|*.xls|*.xlsx|*.ppt|*.pptx) mover_archivo "$archivo" "$DIRECTORIO/${CARPETAS[Documentos]}" ;;
                *.mp4|*.avi|*.mkv|*.mov|*.flv) mover_archivo "$archivo" "$DIRECTORIO/${CARPETAS[Videos]}" ;;
                *.mp3|*.wav|*.aac|*.flac) mover_archivo "$archivo" "$DIRECTORIO/${CARPETAS[Audios]}" ;;
                *) mover_archivo "$archivo" "$DIRECTORIO/${CARPETAS[Otros]}" ;;
            esac
        fi
    done
    echo "Clasificación completada."
}

# Mostrar el contenido de las carpetas
mostrar_contenido() {
    echo "Contenido de las carpetas organizadas en $DIRECTORIO:"
    for carpeta in "${CARPETAS[@]}"; do
        echo "Archivos en $carpeta:"
        ls "$DIRECTORIO/$carpeta" 2>/dev/null || echo "    (Vacío)"
    done
}

# Limpiar las carpetas creadas
limpiar_carpetas() {
    read -p "¿Estás seguro de que deseas eliminar el contenido clasificado? [s/n] " confirm
    if [[ "$confirm" == "s" || "$confirm" == "S" ]]; then
        for carpeta in "${CARPETAS[@]}"; do
            rm -rf "$DIRECTORIO/$carpeta"/*
        done
        echo "Contenido eliminado."
    else
        echo "Operación cancelada."
    fi
}

# Mostrar el menú
mostrar_menu() {
    echo ""
    echo "Organizador de archivos - Menú"
    echo "1. Crear carpetas de organización"
    echo "2. Clasificar archivos"
    echo "3. Mostrar contenido clasificado"
    echo "4. Limpiar carpetas"
    echo "5. Salir"
    echo ""
}

# Función principal del script
main() {
    while true; do
        mostrar_menu
        read -p "Selecciona una opción [1-5]: " opcion
        case $opcion in
            1) crear_carpetas ;;
            2) clasificar_archivos ;;
            3) mostrar_contenido ;;
            4) limpiar_carpetas ;;
            5) echo "Saliendo..."; exit 0 ;;
            *) echo "Opción no válida. Por favor, selecciona una opción del 1 al 5." ;;
        esac
    done
}

# Ejecutar función principal
main
