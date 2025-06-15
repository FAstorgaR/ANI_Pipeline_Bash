#!/bin/bash

# === ENTRADA INTERACTIVA ===
read -p "Ingresa el taxID del organismo: " TAXID

# === CONFIGURACIÓN ===
FORMAT="fasta"                  # Cambia a gbff, gff, etc. si lo necesitas
ASSEMBLY_LEVEL="complete"       # Opciones: complete, chromosome, scaffold, contig
OUTPUT_DIR="genomes_tax_$TAXID" # Carpeta de salida

# === VALIDACIÓN ===
if [ -z "$TAXID" ]; then
    echo "[-] No se ingresó un taxID válido. Abortando."
    exit 1
fi

# === OBTENER NOMBRE CIENTÍFICO ===
echo "[+] Obteniendo nombre científico para taxID $TAXID..."
SCIENTIFIC_NAME=$(curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=taxonomy&id=$TAXID" | grep -oPm1 "(?<=<Item Name=\"ScientificName\" Type=\"String\">)[^<]+")

if [ -z "$SCIENTIFIC_NAME" ]; then
    echo "[-] No se encontró nombre científico para el taxID $TAXID"
    exit 1
fi

echo "[+] Organismo: $SCIENTIFIC_NAME"



# === DESCARGA DE GENOMAS ===
echo "[+] Descargando genomas ($ASSEMBLY_LEVEL) en formato $FORMAT..."

mkdir -p "$OUTPUT_DIR"

# Extraer solo el género (primer nombre)
GENUS=$(echo "$SCIENTIFIC_NAME" | awk '{print $1}')

ncbi-genome-download bacteria \
    --section refseq \
    --assembly-level "$ASSEMBLY_LEVEL" \
    --formats "$FORMAT" \
    --output-folder "$OUTPUT_DIR" \
    --genera "$GENUS"


# === RESUMEN DE DESCARGA ===
echo ""
echo "[✓] Descarga completada en: $OUTPUT_DIR"

# Buscar los archivos descargados
FILES_FOUND=$(find "$OUTPUT_DIR" -type f -name "*.fna.gz" | wc -l)

if [ "$FILES_FOUND" -eq 0 ]; then
    echo "[-] No se encontraron genomas descargados. Puede que el taxID no tenga datos en RefSeq bajo '$GENUS'."
else
    echo "[+] Se descargaron $FILES_FOUND genomas:"
    find "$OUTPUT_DIR" -type f -name "*.fna.gz" | sed 's/^/ - /'
fi
