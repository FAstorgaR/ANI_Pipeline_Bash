#!/bin/bash

INPUT_DIR="genomes_download"
declare -A FOLDER_MAP  # Almacena pares: carpeta original → nuevo nombre

echo "📂 Buscando archivos .fna.gz en: $INPUT_DIR"

# === PRIMER PASO: renombrar archivos ===
find "$INPUT_DIR" -type f -name "*.fna.gz" | while read file; do
    echo "🔍 Procesando archivo: $file"

    HEADER=$(zcat "$file" | head -n 1)
    SPECIES=$(echo "$HEADER" | awk '{print $2 "_" $3}' | sed 's/[^a-zA-Z_]/_/g')

    if [ -z "$SPECIES" ]; then
        SPECIES="Desconocido"
    fi

    GCF=$(basename "$file" | cut -d'_' -f1-2)
    NEW_NAME="${SPECIES}_${GCF}.fna.gz"
    NEW_PATH="$(dirname "$file")/$NEW_NAME"

    echo "➡️ Renombrando archivo a: $NEW_NAME"
    mv "$file" "$NEW_PATH"

    # Guardar carpeta para renombrarla después
    ORIG_FOLDER=$(dirname "$file")
    FOLDER_MAP["$ORIG_FOLDER"]="${SPECIES}_${GCF}"
done

# === SEGUNDO PASO: renombrar carpetas ===
echo ""
echo "📁 Renombrando carpetas..."
for OLD in "${!FOLDER_MAP[@]}"; do
    NEW="${FOLDER_MAP[$OLD]}"
    PARENT=$(dirname "$OLD")
    TARGET="$PARENT/$NEW"

    if [ "$OLD" != "$TARGET" ]; then
        echo "📁 $OLD → $TARGET"
        mv "$OLD" "$TARGET"
    fi
done

echo "✅ Proceso completado. Si usas un explorador gráfico, recarga o reinícialo si no ves los cambios."
