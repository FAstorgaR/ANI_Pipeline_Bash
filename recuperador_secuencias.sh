#!/bin/bash

read -p "Ingresa el taxID del organismo: " TAXID

FORMAT="fasta"
OUTPUT_DIR="genomes_tax_$TAXID"

if [ -z "$TAXID" ]; then
    echo "[-] No se ingresó un taxID válido. Abortando."
    exit 1
fi

# Obtener nombre científico
echo "[+] Obteniendo nombre científico para taxID $TAXID..."
SCIENTIFIC_NAME=$(curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=taxonomy&id=$TAXID" | grep -oPm1 "(?<=<Item Name=\"ScientificName\" Type=\"String\">)[^<]+")

if [ -z "$SCIENTIFIC_NAME" ]; then
    echo "[-] No se encontró nombre científico para el taxID $TAXID"
    exit 1
fi

echo "[+] Organismo detectado: $SCIENTIFIC_NAME"

# Preguntar tipo de búsqueda
echo ""
echo "Selecciona el tipo de descarga:"
echo "1) Por género (descarga todo el género)"
echo "2) Por especie (filtra especie dentro del género)"
echo "3) Exacto (por taxID, útil para variedades/patovares)"
read -p "Opción [1-3]: " OPTION

# Extraer género
GENUS=$(echo "$SCIENTIFIC_NAME" | awk '{print $1}')

# Crear carpeta
mkdir -p "$OUTPUT_DIR"

case $OPTION in
  1)
    echo "[+] Descargando TODO el género: $GENUS"
    ncbi-genome-download bacteria \
      --section refseq \
      --formats "$FORMAT" \
      --output-folder "$OUTPUT_DIR" \
      --genera "$GENUS"
    ;;
  2)
    echo "[+] Descargando especies del género $GENUS y luego filtrando por nombre '$SCIENTIFIC_NAME' (requiere limpieza posterior)"
    ncbi-genome-download bacteria \
      --section refseq \
      --formats "$FORMAT" \
      --output-folder "$OUTPUT_DIR" \
      --genera "$GENUS"
    ;;
  3)
    echo "[+] Descargando genomas exactamente por taxID: $TAXID"
    ncbi-genome-download bacteria \
      --section refseq \
      --formats "$FORMAT" \
      --output-folder "$OUTPUT_DIR" \
      --species-taxids "$TAXID"
    ;;
  *)
    echo "[-] Opción inválida. Abortando."
    exit 1
    ;;
esac

echo ""
echo "[✓] Descarga terminada. Verifica contenido en: $OUTPUT_DIR"
