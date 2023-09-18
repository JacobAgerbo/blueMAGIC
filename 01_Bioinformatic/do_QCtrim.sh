#!/bin/sh
module load trimmomatic kraken2/2.1.2 pigz/2.6.0
DATA='/projects/mjolnir1/people/bfg522/04_Marine_Mining/00_RawData/PILOT'
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

# Trim data to remove low quality reads
# Define the quality filtering function
  # Set the sample name and input file names
  sample_name=$1
  input_file_1=$DATA/${sample_name}_1.fastq.gz
  input_file_2=$DATA/${sample_name}_2.fastq.gz

  # Set the output file names
  output_file_1=$OUT/${sample_name}_filtered_1.fastq.gz
  output_file_2=$OUT/${sample_name}_filtered_2.fastq.gz

  # Run Trimmomatic with the desired settings
  trimmomatic PE -threads $SLURM_CPUS_PER_TASK -phred33 $input_file_1 $input_file_2 $output_file_1 /dev/null $output_file_2 /dev/null LEADING:20 TRAILING:20 SLIDINGWINDOW:4:20 MINLEN:50