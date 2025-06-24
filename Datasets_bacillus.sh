datasets download genome taxon 1386 \
  --exclude-atypical \
  --assembly-level complete \
  --assembly-source RefSeq \
  --include genome,cds,protein \
  --dehydrated \
  --filename bacillus_refseq.zip
unzip bacillus_refseq.zip -d bacillus_dataset
cd bacillus_dataset
datasets rehydrate --directory .
