#!/bin/bash
TMPDIR="/projects/mjolnir1/people/bfg522/04_Marine_Mining/05_ARGs/tmp"
TMP=$TMPDIR
TEMP=$TMPDIR

export TMPDIR TMP TEMP
module load miniconda
module load rgi/6.0.1
module load samtools
module load bamtools
#conda activate rgi
DATA="/projects/mjolnir1/people/bfg522/04_Marine_Mining/05_ARGs/00_DATA"
OUT="/projects/mjolnir1/people/bfg522/04_Marine_Mining/05_ARGs"

for sample in ${1}
  do
    echo "starts on finding ARG in:"$sample""
    rgi main --input_sequence $DATA/"$sample".contigs.fa --output_file $OUT/01_Results --local --low_quality --include_nudge --num_threads $SLURM_CPUS_PER_TASK
done