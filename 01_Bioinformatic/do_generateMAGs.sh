#!/bin/sh
module load kaiju anvio bwa samtools

# Set the paths to the input files and output directory
READS="/projects/mjolnir1/people/bfg522/04_Marine_Mining/01_No_EUK"
CONTIGS="/projects/mjolnir1/people/bfg522/04_Marine_Mining/02_Assemblies"
OUT="/projects/mjolnir1/people/bfg522/04_Marine_Mining/06_MAGs"

# Set the input file names based on the user input
read1="$READS/noEUK_$1_1.fq.gz"
read2="$READS/noEUK_$1_2.fq.gz"

# Print the starting message
echo "Starting genome-resolved metagenomics on: $1"

# Do HMMS - important for anvi'o
anvi-run-hmms -c "$OUT/$1/CONTIGS.db" --num-threads "$SLURM_CPUS_PER_TASK"

# Index contigs for profiling
if [ -f "$CONTIGS/$1/contigs*.fa.ann" ]; then
  echo "Indexed references exist, skipping bwa index"
else
  echo "Indexed references do not exist, running bwa index"
  bwa index "$CONTIGS/$1/contigs-fixed.fa"
fi

# Align reads to contigs using bwa
bwa mem -t "$SLURM_CPUS_PER_TASK" "$CONTIGS/$1/contigs-fixed.fa" "$read1" "$read2" > "$OUT/$1/$1_aln_pe.sam"

# Convert SAM to BAM
samtools view -@ "$SLURM_CPUS_PER_TASK" -bS "$OUT/$1/$1_aln_pe.sam" > "$OUT/$1/$1_aln_pe.bam"

# Initialize BAM file for anvi'o
anvi-init-bam "$OUT/$1/$1_aln_pe.bam" -o "$OUT/$1/$1_out.bam"

# Profile the BAM file using anvi'o

# Finally, because single profiles are rarely used for genome binning or visualization, 
# and since the clustering step increases the profiling runtime for no good reason, 
# the default behavior of profiling is to not cluster contigs automatically. 
# However, if you are planning to work with single profiles, 
# and if you would like to visualize them using the interactive interface without any merging, 
# you can use the --cluster-contigs flag to initiate clustering of contigs.

anvi-profile -i "$OUT/$1/$1_out.bam" -c "$OUT/$1/CONTIGS.db" -o "$OUT/$1/" -T "$SLURM_CPUS_PER_TASK" --cluster-contigs


# Print the completion message
echo "Done with: $1"