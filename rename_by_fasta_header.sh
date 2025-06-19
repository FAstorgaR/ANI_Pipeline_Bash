#!/bin/bash

INPUT_DIR="genomes_download"

echo "📂 Buscando archivos .fna.gz en: $INPUT_DIR"

find "$INPUT_DIR" -type f -name "*.fna.gz" | while read file; do
    echo "🔍 Procesando archivo: $file"

    # Guardamos nombre original de carpeta antes de mover el archivo
    OLD_DIR=$(dirname "$file")

    # Obtener el encabezado
    HEADER=$(zcat "$file" | head -n 1)

    # Extraer palabras 2 y 3 como nombre científico
    SPECIES=$(echo "$HEADER" | awk '{print $2 "_" $3}' | sed 's/[^a-zA-Z_]/_/g')

    if [ -z "$SPECIES" ]; then
        echo "⚠️ No se pudo extraer nombre de especie. Usando 'Desconocido'"
        SPECIES="Desconocido"
    fi

    # Extraer código GCF
    GCF=$(basename "$file" | cut -d'_' -f1-2)

    # Nuevo nombre de archivo
    NEW_NAME="${SPECIES}_${GCF}.fna.gz"
    NEW_PATH="$OLD_DIR/$NEW_NAME"

    echo "➡️ Renombrando archivo a: $NEW_NAME"
    mv "$file" "$NEW_PATH"

    # === RENOMBRAR CARPETA ===
    # Nuevo nombre de carpeta (solo si no está ya renombrada)
    PARENT_DIR=$(dirname "$OLD_DIR")
    NEW_DIR="${PARENT_DIR}/${SPECIES}_${GCF}"

    if [ "$OLD_DIR" != "$NEW_DIR" ]; then
        echo "📁 Renombrando carpeta: $(basename "$OLD_DIR") → $(basename "$NEW_DIR")"
        mv "$OLD_DIR" "$NEW_DIR"
    fi
done

echo "✅ Proceso completado."

