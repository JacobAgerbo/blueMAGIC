#!/bin/bash
# This script performs a single assembly from metagenomes using MEGAHIT with meta-sensitive presets.
# Load MEGAHIT module
module load megahit

# Set input file paths
DATA="/projects/mjolnir1/people/bfg522/04_Marine_Mining/01_No_EUK"
read1="noEUK_"$1"_1.fq.gz"
read2="noEUK_"$1"_2.fq.gz"

# Run MEGAHIT assembly with meta-sensitive presets
megahit -1 $DATA/$read1 -2 $DATA/$read2 -o $1 --presets meta-sensitive --num-cpu-threads $SLURM_CPUS_PER_TASK --min-contig-len 1000