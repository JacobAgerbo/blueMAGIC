#!/bin/bash
TMPDIR="/projects/mjolnir1/people/bfg522/04_Marine_Mining/04_moreBGC/tmp"
TMP=$TMPDIR
TEMP=$TMPDIR

export TMPDIR TMP TEMP
conda deactivate
conda activate deepbgc
DEEPBGC_DOWNLOADS_DIR=/projects/mjolnir1/people/bfg522/04_Marine_Mining/04_moreBGC/bin
export DEEPBGC_DOWNLOADS_DIR
DATA="/projects/mjolnir1/people/bfg522/04_Marine_Mining/05_ARGs/00_DATA"
OUT="/projects/mjolnir1/people/bfg522/04_Marine_Mining/04_moreBGC/01_RESULTS"
for sample in ${1}
  do
    echo "starts on finding BGCs in:"$sample""
    deepbgc pipeline $DATA/$sample.contigs.fa --prodigal-meta-mode --output $OUT/$sample/
    cp $OUT/$sample/$sample.bgc.tsv $OUT/
done