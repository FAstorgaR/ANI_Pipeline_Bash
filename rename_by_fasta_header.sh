#!/bin/bash

INPUT_DIR="genomes_download"

echo "📂 Buscando archivos .fna.gz en: $INPUT_DIR"

find "$INPUT_DIR" -type f -name "*.fna.gz" | while read file; do
    echo "🔍 Procesando archivo: $file"

    HEADER=$(zcat "$file" | head -n 1)

    # Extraer palabras 2 y 3 del encabezado, que suelen ser el nombre científico
    SPECIES=$(echo "$HEADER" | cut -d' ' -f2,3 | sed 's/[^a-zA-Z ]//g' | tr ' ' '_')

    if [ -z "$SPECIES" ]; then
        echo "⚠️ No se pudo extraer nombre de especie. Usando 'Desconocido'"
        SPECIES="Desconocido"
    fi

    # Extraer código GCF
    GCF=$(basename "$file" | cut -d'_' -f1-2)

    # Nuevo nombre de archivo
    NEW_NAME="${SPECIES}_${GCF}.fna.gz"
    NEW_PATH="$(dirname "$file")/$NEW_NAME"

    echo "➡️ Renombrando archivo a: $NEW_NAME"
    mv "$file" "$NEW_PATH"

    # Renombrar carpeta contenedora
    OLD_DIR=$(dirname "$file")
    NEW_DIR="$(dirname "$OLD_DIR")/${SPECIES}_${GCF}"

    if [ "$OLD_DIR" != "$NEW_DIR" ]; then
        echo "📁 Renombrando carpeta: $(basename "$OLD_DIR") → $(basename "$NEW_DIR")"
        mv "$OLD_DIR" "$NEW_DIR"
    fi
done

echo "✅ Proceso completado."
