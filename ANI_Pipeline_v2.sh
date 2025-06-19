#!/bin/bash

# Ruta base donde están los genomas renombrados y organizados
OUTDIR="organismos_ordenados"

# -------------------- DESCOMPRESIÓN --------------------

echo "📦 Descomprimiendo archivos .fna.gz en $OUTDIR si existen..."
find "$OUTDIR" -type f -name "*.fna.gz" -exec gunzip -f {} \;

# -------------------- CREAR LISTAS DE GENOMAS --------------------

echo "📃 Generando lista de archivos .fna desde $OUTDIR..."
# Buscamos todos los .fna (descomprimidos) en subcarpetas
find "$OUTDIR" -type f -name "*.fna" > genome_list.txt

N_GENOMES=$(wc -l < genome_list.txt)
echo "✅ Se encontraron $N_GENOMES genomas FASTA"

if [[ $N_GENOMES -lt 2 ]]; then
    echo "❌ Se necesitan al menos 2 genomas para análisis ANI. Abortando."
    exit 1
fi

# -------------------- SKANI TRIANGLE --------------------

echo "🧠 Ejecutando skani (triangle)..."
skani triangle -l genome_list.txt -o skani_output.tsv -t 2 || {
    echo "❌ Error ejecutando skani. Abortando."
    exit 1
}

# -------------------- FASTANI --------------------

echo "🧠 Ejecutando fastANI..."

# Para fastANI, copiamos la lista para query y ref (todos contra todos)
cp genome_list.txt fastani_query_list.txt
cp genome_list.txt fastani_ref_list.txt

fastANI --ql fastani_query_list.txt \
        --rl fastani_ref_list.txt \
        -o fastani_output.tsv \
        --fragLen 3000 \
        -t 2 || {
    echo "❌ Error ejecutando fastANI. Abortando."
    exit 1
}

# -------------------- FINAL --------------------

echo ""
echo "✅ Proceso finalizado."
echo "🧾 Resultados:"
echo "   - SKANI:     skani_output.tsv"
echo "   - FASTANI:   fastani_output.tsv"
echo "📂 Genomas:    $OUTDIR"
