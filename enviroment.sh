conda create -n ani_env -c bioconda -c conda-forge \
    ncbi-genome-download \
    skani \
    fastani \
    entrez-direct \
    -y
conda activate ani_env
