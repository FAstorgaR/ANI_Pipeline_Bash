#!/bin/bash

INPUT_DIR="genomes_download"

echo "📂 Buscando subcarpetas en: $INPUT_DIR"

find "$INPUT_DIR" -mindepth 1 -maxdepth 1 -type d | while read folder; do
    echo "📁 Procesando carpeta: $folder"

    # Buscar archivo .fna.gz
    FILE=$(find "$folder" -type f -name "*.fna.gz" | head -n 1)

    if [ -z "$FILE" ]; then
        echo "⚠️ No se encontró archivo .fna.gz en $folder"
        continue
    fi

    # Leer encabezado
    HEADER=$(zcat "$FILE" | head -n 1)
    SPECIES=$(echo "$HEADER" | awk '{print $2 "_" $3}' | sed 's/[^a-zA-Z_]/_/g')

    if [ -z "$SPECIES" ]; then
        SPECIES="Desconocido"
    fi

    GCF=$(basename "$FILE" | cut -d'_' -f1-2)
    NEW_NAME="${SPECIES}_${GCF}.fna.gz"
    NEW_FILE_PATH="$folder/$NEW_NAME"

    echo "➡️ Renombrando archivo a: $NEW_NAME"
    mv "$FILE" "$NEW_FILE_PATH"

    # Renombrar carpeta
    PARENT_DIR=$(dirname "$folder")
    NEW_FOLDER_NAME="${SPECIES}_${GCF}"
    NEW_FOLDER_PATH="$PARENT_DIR/$NEW_FOLDER_NAME"

    if [ "$folder" != "$NEW_FOLDER_PATH" ]; then
        echo "📁 Renombrando carpeta: $(basename "$folder") → $NEW_FOLDER_NAME"
        mv "$folder" "$NEW_FOLDER_PATH"
    fi
done

echo "✅ Proceso completado. Si usas un explorador gráfico, recarga o reinícialo si no ves los cambios."
