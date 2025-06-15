# ANI Pipeline en Bash para Organismos por taxID

Este pipeline automatiza la descarga de genomas desde NCBI RefSeq a partir de un taxID, descomprime los archivos, genera listas de genomas y calcula matrices de ANI utilizando `skani` y `fastANI`.

---

## 🧰 Requisitos

Instala los siguientes paquetes con Conda (recomendado) o apt:

```bash
conda create -n ani_env -c bioconda -c conda-forge \
  ncbi-genome-download fastani skani entrez-direct -y

conda activate ani_env
```

---

## 🚀 Uso

```bash
./recuperador_secuencias.sh
./ani_pipeline.sh
```

El script te pedirá el taxID del organismo. Ejemplo para *Bacillus*:

```
Ingresa el taxID del organismo:
1386
```

El pipeline realizará las siguientes tareas:

1. Consulta el nombre científico del taxID usando Entrez.
2. Descarga todos los genomas **completos** de RefSeq para ese género.
3. Descomprime todos los `.fna.gz`.
4. Genera un archivo `genome_list.txt` con las rutas a los genomas.
5. Ejecuta:
   - `skani triangle`: genera matriz ANI con `skani`.
   - `fastANI`: genera matriz ANI con `fastANI`.

---

## 📂 Archivos generados

- `genomes_tax_<taxid>/`: carpeta con los genomas descargados.
- `genome_list.txt`: lista de archivos `.fna` usados como input.
- `skani_output.tsv`: matriz ANI generada por `skani`.
- `fastani_output.tsv`: resultados ANI generados por `fastANI`.

---

## 🧪 Ejemplo rápido

```bash
chmod +x ani_pipeline.sh
./ani_pipeline.sh
# Ingresa: 1386
```

---

## 📝 Notas

- El script usa `esearch`, `efetch` y `xtract` del paquete `entrez-direct`.
- El argumento `--genera` se usa en lugar de `--genus`, ya que es la opción actual soportada por `ncbi-genome-download`.
- La descarga está restringida a genomas completos (`--assembly-level complete`) en RefSeq.

---

## 📚 Referencias

- [skani](https://github.com/bluenote-1577/skani)
- [fastANI](https://github.com/ParBLiSS/FastANI)
- [ncbi-genome-download](https://github.com/kblin/ncbi-genome-download)
- [Entrez Direct](https://www.ncbi.nlm.nih.gov/books/NBK179288/)

---
