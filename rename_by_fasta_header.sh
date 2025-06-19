#!/bin/bash

# Directorio con archivos .fna.gz
INPUT_DIR="genomes_download"

echo "📂 Buscando archivos .fna.gz en: $INPUT_DIR"
find "$INPUT_DIR" -type f -name "*.fna.gz" | while read file; do
    echo "🔍 Procesando: $file"

    # Extraer el encabezado (1ra línea) del archivo fasta
    HEADER=$(zcat "$file" | head -n 1)

    # Intentar extraer el nombre científico (usualmente después de ">" y hasta [)
    SPECIES=$(echo "$HEADER" | grep -oP '\[.*?\]' | head -n 1 | tr -d '[]' | tr ' ' '_')

    # Si no se encuentra, usar "Desconocido"
    if [ -z "$SPECIES" ]; then
        echo "⚠️ No se pudo extraer el nombre de especie. Usando 'Desconocido'"
        SPECIES="Desconocido"
    fi

    # Extraer el código GCF
    GCF=$(basename "$file" | cut -d'_' -f1-2)

    # Generar nuevo nombre
    NEW_NAME="${SPECIES}_${GCF}.fna.gz"
    NEW_PATH="$(dirname "$file")/$NEW_NAME"

    echo "➡️ Renombrando a: $NEW_NAME"
    mv "$file" "$NEW_PATH"
done

echo "✅ Proceso completado."
