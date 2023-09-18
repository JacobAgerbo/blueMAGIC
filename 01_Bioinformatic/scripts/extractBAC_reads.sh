#!/bin/sh
conda deactivate #ensure no conflicts
conda activate KRAKEN # load biopython
DATA='/projects/mjolnir1/people/bfg522/04_Marine_Mining/01_No_EUK'
OUT='/projects/mjolnir1/people/bfg522/04_Marine_Mining/01_No_EUK'

if [[ -O /home/$USER/tmp && -d /home/$USER/tmp ]]; then
        TMPDIR=/home/$USER/tmp
else
        # You may wish to remove this line, it is there in case
        # a user has put a file 'tmp' in there directory or a
        rm -rf /home/$USER/tmp 2> /dev/null
        mkdir -p /home/$USER/tmp
        TMPDIR=$(mktemp -d /home/$USER/tmp/XXXX)
fi

TMP=$TMPDIR
TEMP=$TMPDIR

export TMPDIR TMP TEMP

# Remove eukaryotic data from the metagenome

/projects/mjolnir1/apps/bin/extract_kraken_readsBB.py -k  $OUT/"$1"_12_krk2_500.kraken2.gz  -s1 $DATA/"$1"_filtered_1.fastq.gz  -s2 $DATA/"$1"_filtered_2.fastq.gz -o $OUT/noEUK_"$1"_1.fq -o2 $OUT/noEUK_"$1"_2.fq --fastq-output  --exclude
--taxid 2759 --include-children  -r $OUT/"$1"_12_krk2_500.kraken2.report.gz

pigz -p $SLURM_CPUS_PER_TASK $OUT/noEUK_"$1"_1.fq $OUT/noEUK_"$1"_2.fq
echo ""$1" is done" > $OUT/done."$1"