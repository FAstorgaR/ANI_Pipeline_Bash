#!/bin/bash

INPUT_DIR="genomes_download"
OUTPUT_BASE_DIR="organismos_ordenados"

mkdir -p "$OUTPUT_BASE_DIR"

echo "📂 Buscando archivos .fna.gz en: $INPUT_DIR"

find "$INPUT_DIR" -type f -name "*.fna.gz" | while read file; do
    echo "🔍 Procesando archivo: $file"

    # Extraer la primera línea del archivo (encabezado FASTA)
    HEADER=$(zcat "$file" | head -n 1)

    # Extraer palabras 2 y 3 como nombre científico
    SPECIES=$(echo "$HEADER" | awk '{print $2 "_" $3}' | sed 's/[^a-zA-Z_]/_/g')

    if [ -z "$SPECIES" ]; then
        echo "⚠️ No se pudo extraer nombre de especie. Usando 'Desconocido'"
        SPECIES="Desconocido"
    fi

    # Extraer el ID tipo GCF_XXXXXX
    GCF=$(basename "$file" | cut -d'_' -f1-2)

    # Nuevo nombre de archivo
    NEW_NAME="${SPECIES}_${GCF}.fna.gz"
    NEW_PATH="$(dirname "$file")/$NEW_NAME"

    echo "➡️ Renombrando archivo a: $NEW_NAME"
    mv "$file" "$NEW_PATH"

    # Crear carpeta de salida para la especie
    SPECIES_DIR="$OUTPUT_BASE_DIR/$SPECIES"
    mkdir -p "$SPECIES_DIR"
done

echo ""
echo "📂 Moviendo todos los archivos FASTA (.fna y .fna.gz) renombrados a sus carpetas..."

# Mover todos los archivos .fna y .fna.gz al folder correspondiente basado en su nombre
find "$INPUT_DIR" \( -name "*.fna" -o -name "*.fna.gz" \) | while read fasta_file; do
    # Extraer nombre de especie del nombre del archivo (antes del primer guion bajo)
    BASENAME=$(basename "$fasta_file")
    # Extraemos desde el inicio hasta el segundo guion bajo, que es especie + GCF
    SPECIES_PART=$(echo "$BASENAME" | cut -d'_' -f1,2)

    DEST_DIR="$OUTPUT_BASE_DIR/$SPECIES_PART"
    mkdir -p "$DEST_DIR"

    echo "➡️ Moviendo $BASENAME a $DEST_DIR"
    mv "$fasta_file" "$DEST_DIR/"
done

echo "✅ Proceso completado."
