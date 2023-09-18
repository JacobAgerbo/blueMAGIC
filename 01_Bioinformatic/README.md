# Bioinformatics for blueMAGIC
blueMAGIC: Marine Analysis for metaGenomic Identification of bioactive microbial Compounds

In this Github repository all code will be presented in the best way to increase FAIRness of the research.

## Overview
We will post all scripts related to bioinformatics [**here**](https://github.com/JacobAgerbo/blueMAGIC/), including: 

- Data retrievel (Soon to become automated)
- Quality Control
- Microbial profiling with KAIJU
- Genome-resolved Metagenomics
- Recovering biosynthetic gene clusters (BGCs)
- Mining for antibacterial resistance genes (ARGs)

## Data retrievel

Here is a script for downloading the first 50 marine metagenomes of interest. Full list will also be available [**here**](https://github.com/JacobAgerbo/blueMAGIC/tree/main/01_Bioinformatic/assets/ALL_ACCESSIONS.TXT).

The scripts is dependent on *sra-tools* and *gnu-parallels*.

```{bash}
bash ./scripts/get_data.sh assets/FIRST_50.txt
```

## Quality control
### Read trimming
All data will quality control with a minimal filtering using *trimmomatic*, script can be assessed [**here**](https://github.com/JacobAgerbo/blueMAGIC/tree/main/01_Bioinformatic/scripts/do_QCtrim.sh).

```{bash}
#Below is an example for running one sample.
bash scripts/do_QCtrim.sh SRR5916561

# Optimal would be a slurm system to run multiple sample simultaneusly, as done below. 
# Set the path to the directory containing the input files
# Read the list of input files from a file into an array
mapfile -t FILES < assets/FIRST_50.txt

# Loop through the array of input files and generate an SBATCH submission line for each file
for file in "${FILES[@]}"; do
    # Define the command to run on each file
    CMD="scripts/do_QCtrim.sh $file"
    # Define the SBATCH submission line for each file
    SUBMIT_LINE="sbatch --job-name=$file --out=$file.out --time=05:00:00 --mem=64G --cpus-per-task=12 $CMD"
    # Submit the SBATCH job for each file
    eval $SUBMIT_LINE
done
```
### Eukaryotic and prokaryotic seperation

All reads are being seperated between eukaryotic and prokaryotic data to increase assembly efficiency. 
This will be based in two steps. Running tax classification with *KRAKEN* and running post-hoc script to seperate reads.

**Classification of reads with KRAKEN**
```{bash}
#Below is an example for running one sample.
bash scripts/removeEUK.sh SRR5916561

# Optimal would be a slurm system to run multiple sample simultaneusly, as done below. 
# Set the path to the directory containing the input files
# Read the list of input files from a file into an array
mapfile -t FILES < assets/FIRST_50.txt

# Loop through the array of input files and generate an SBATCH submission line for each file
for file in "${FILES[@]}"; do
    # Define the command to run on each file
    CMD="scripts/do_QCtrim.sh $file"
    # Define the SBATCH submission line for each file
    SUBMIT_LINE="sbatch --job-name=$file --out=$file.out --time=05:00:00 --mem=64G --cpus-per-task=12 $CMD"
    # Submit the SBATCH job for each file
    eval $SUBMIT_LINE
done
```