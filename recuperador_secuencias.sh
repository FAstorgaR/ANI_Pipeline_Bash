#!/bin/bash

# === MODO DE OPERACIÓN ===
echo "¿Deseas descargar un (1) género completo o una (2) especie específica por taxID?"
read -p "Elige 1 (género) o 2 (especie): " MODO

if [[ "$MODO" == "1" ]]; then
    read -p "Ingresa el nombre del género (ej: Bacillus): " GENUS
    if [ -z "$GENUS" ]; then
        echo "[-] No se ingresó un nombre de género válido. Abortando."
        exit 1
    fi
    MODE_DESC="género $GENUS"
elif [[ "$MODO" == "2" ]]; then
    read -p "Ingresa el taxID de la especie: " TAXID
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
    MODE_DESC="especie $SCIENTIFIC_NAME"
else
    echo "[-] Opción no válida. Abortando."
    exit 1
fi

# === CONFIGURACIÓN GENERAL ===
FORMAT="fasta"
ASSEMBLY_LEVEL="complete"
OUTPUT_DIR="genomes_download"

mkdir -p "$OUTPUT_DIR"

# === DESCARGA DE GENOMAS ===
echo "[+] Descargando genomas ($ASSEMBLY_LEVEL, $FORMAT) para $MODE_DESC..."

if [[ "$MODO" == "1" ]]; then
    ncbi-genome-download bacteria \
        --section refseq \
        --assembly-level "$ASSEMBLY_LEVEL" \
        --formats "$FORMAT" \
        --output-folder "$OUTPUT_DIR" \
        --genera "$GENUS"
else
    ncbi-genome-download bacteria \
        --section refseq \
        --assembly-level "$ASSEMBLY_LEVEL" \
        --formats "$FORMAT" \
        --output-folder "$OUTPUT_DIR" \
        --species-taxids "$TAXID"
fi

# === RESUMEN ===
echo ""
FILES_FOUND=$(find "$OUTPUT_DIR" -type f -name "*.fna.gz" | wc -l)
if [ "$FILES_FOUND" -eq 0 ]; then
    echo "[-] No se encontraron genomas descargados."
else
    echo "[✓] Se descargaron $FILES_FOUND archivos:"
    find "$OUTPUT_DIR" -type f -name "*.fna.gz" | sed 's/^/ - /'
fi
