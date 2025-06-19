#!/bin/bash

# === MODO DE OPERACIÓN ===
echo "¿Qué deseas descargar?"
echo "1) Género completo (ej: Bacillus)"
echo "2) Especie exacta (por taxID, con filtrado)"
echo "3) Filtrar especie/patovar desde un género (por nombre)"
read -p "Elige 1, 2 o 3: " MODO

# === CONFIGURACIÓN GENERAL ===
FORMAT="fasta"
ASSEMBLY_LEVEL="complete"
OUTPUT_DIR="genomes_download"
mkdir -p "$OUTPUT_DIR"

if [[ "$MODO" == "1" ]]; then
    read -p "Ingresa el nombre del género (ej: Bacillus): " GENUS
    if [ -z "$GENUS" ]; then
        echo "[-] No se ingresó un nombre de género válido. Abortando."
        exit 1
    fi
    MODE_DESC="género $GENUS"

    echo "[+] Descargando genomas ($ASSEMBLY_LEVEL, $FORMAT) para $MODE_DESC..."
    ncbi-genome-download bacteria \
        --section refseq \
        --assembly-level "$ASSEMBLY_LEVEL" \
        --formats "$FORMAT" \
        --output-folder "$OUTPUT_DIR" \
        --genera "$GENUS"

elif [[ "$MODO" == "2" ]]; then
    read -p "Ingresa el taxID de la especie (ej: 323): " TAXID
    if [ -z "$TAXID" ]; then
        echo "[-] No se ingresó un taxID válido. Abortando."
        exit 1
    fi

    # Obtener nombre científico
    SCIENTIFIC_NAME=$(curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=taxonomy&id=$TAXID" | grep -oPm1 "(?<=<Item Name=\"ScientificName\" Type=\"String\">)[^<]+")
    if [ -z "$SCIENTIFIC_NAME" ]; then
        echo "[-] No se encontró nombre científico para el taxID $TAXID"
        exit 1
    fi
    echo "[+] Organismo detectado: $SCIENTIFIC_NAME"

    echo "[+] Descargando genomas ($ASSEMBLY_LEVEL, $FORMAT) para especie $SCIENTIFIC_NAME..."
    ncbi-genome-download bacteria \
        --section refseq \
        --assembly-level "$ASSEMBLY_LEVEL" \
        --formats "$FORMAT" \
        --output-folder "$OUTPUT_DIR" \
        --species-taxids "$TAXID"

    echo "[+] Filtrando solo genomas cuyo encabezado contenga: '$SCIENTIFIC_NAME'"
    mkdir -p "$OUTPUT_DIR/filtrados"
    find "$OUTPUT_DIR" -type f -name "*.fna.gz" | while read fna; do
        if zcat "$fna" | grep -qi "$SCIENTIFIC_NAME"; then
            echo "  ✔️ Match: $(basename "$fna")"
            cp "$fna" "$OUTPUT_DIR/filtrados/"
        fi
    done

    echo ""
    echo "✅ Genomas filtrados disponibles en: $OUTPUT_DIR/filtrados/"
    exit 0

elif [[ "$MODO" == "3" ]]; then
    read -p "Ingresa el taxID de la especie/patovar a buscar: " TAXID
    if [ -z "$TAXID" ]; then
        echo "[-] No se ingresó un taxID válido. Abortando."
        exit 1
    fi

    # Obtener nombre científico
    SCIENTIFIC_NAME=$(curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=taxonomy&id=$TAXID" | grep -oPm1 "(?<=<Item Name=\"ScientificName\" Type=\"String\">)[^<]+")
    if [ -z "$SCIENTIFIC_NAME" ]; then
        echo "[-] No se encontró nombre científico para el taxID $TAXID"
        exit 1
    fi
    echo "[+] Organismo: $SCIENTIFIC_NAME"

    GENUS=$(echo "$SCIENTIFIC_NAME" | awk '{print $1}')
    echo "[+] Descargando genomas ($ASSEMBLY_LEVEL, $FORMAT) para género $GENUS..."
    ncbi-genome-download bacteria \
        --section refseq \
        --assembly-level "$ASSEMBLY_LEVEL" \
        --formats "$FORMAT" \
        --output-folder "$OUTPUT_DIR" \
        --genera "$GENUS"

    echo "[+] Filtrando genomas que contengan: '$SCIENTIFIC_NAME'"
    mkdir -p "$OUTPUT_DIR/filtrados"
    find "$OUTPUT_DIR" -type f -name "*.fna.gz" | while read fna; do
        if zcat "$fna" | grep -qi "$SCIENTIFIC_NAME"; then
            echo "  ✔️ Match: $(basename "$fna")"
            cp "$fna" "$OUTPUT_DIR/filtrados/"
        fi
    done

    echo ""
    echo "✅ Genomas filtrados disponibles en: $OUTPUT_DIR/filtrados/"
    exit 0

else
    echo "[-] Opción no válida. Abortando."
    exit 1
fi

# === RESUMEN GENERAL PARA OPCIÓN 1 ===
echo ""
FILES_FOUND=$(find "$OUTPUT_DIR" -type f -name "*.fna.gz" | wc -l)
if [ "$FILES_FOUND" -eq 0 ]; then
    echo "[-] No se encontraron genomas descargados."
else
    echo "[✓] Se descargaron $FILES_FOUND archivos:"
    find "$OUTPUT_DIR" -type f -name "*.fna.gz" | sed 's/^/ - /'
fi
