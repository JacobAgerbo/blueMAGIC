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

## Data retrieval

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
```

Optimal would be a slurm system to run multiple sample simultaneusly, as done below. 
```{bash}
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
*Remember that you can run SLURM script above, just change in commandline alias to* `CMD="scripts/removeEUK.sh $file"`. 

```{bash}
#Below is an example for running one sample.
bash scripts/removeEUK.sh SRR5916561
```

**Seperation of reads with based KRAKEN report**
*Remember that you can run SLURM script above, just change in commandline alias to* `CMD="scripts/extractBAC_reads.sh $file"`.

```{bash}
#Below is an example for running one sample.
bash scripts/extractBAC_reads.sh SRR5916561
```
## Running MEGAHIT for single assemblies

**MEGAHIT and SPAdes are both popular tools for metagenomic assembly.**
Assembly is important for investigating the subsequent parts, like bacterial richness, BGCs, phages, and ARGs. 

MEGAHIT is known for its efficiency and speed in assembling large and complex metagenomic datasets. It utilizes a succinct de Bruijn graph data structure, which allows for memory-efficient assembly. MEGAHit also incorporates various algorithms to handle uneven coverage and reduce chimeric contigs.

On the other hand, SPAdes is a versatile metagenomic assembly tool that offers more advanced features. It can handle both short and long reads, including paired-end and mate-pair libraries. SPAdes also provides options for error correction, scaffolding, and gap filling, which can improve the quality of the assembly.

The choice between MEGAHit and SPAdes depends on the specific requirements of your metagenomic project. If you are working with large datasets and prioritize speed, MEGAHit is a good choice. 

Here we use MEGAHIT for a memory-efficient processing. We combine it with the meta-sensitive preset for metagenomic assembly. This preset is designed for metagenomes that are complex and diverse, such as soil metagenomes. It uses a k-mer length of 21, 29, 39, 59, 79, 99, and 119 to build the de Bruijn graph, which allows for better handling of complex metagenomes. 

Furthermore, we filter out contigs, which are smaller than 1 Kb, since these contigs often are **rubish**. 

```{bash}
#Below is an example for running one sample.
bash scripts/do_Assembly.sh SRR5916561
```
*Remember that you can run SLURM script above, just change in commandline alias to* `CMD="scripts/do_Assembly.sh $file"`.

## Profiling with Kaiju
[**Kaiju**](https://bioinformatics-centre.github.io/kaiju/), is a bioinformatics tool used for bacterial profiling. It is designed to analyze metagenomic sequencing data and identify the presence of bacterial species in a given sample.

Several reference protein databases can be used, such as complete genomes from NCBI RefSeq or the microbial subset of the NCBI BLAST non-redundant protein database nr, optionally also including fungi and microbial eukaryotes.

Here, we use the nr database including fungi and microbial eukaryotes to as most comprehensive as possible. 

While running KAIJI profiles, we do this through the anvi'o [pipeline](https://merenlab.org/2016/06/18/importing-taxonomy/). Since these contigs will be used for genome-resolved metagenomics afterwards. 

Therefore, we generate the needed files for using anvi'o in combination with automated binning, using METABAT2 and CONCOCT.

In short, 
- contigs.fa will be renamed and subquently will be made to a SQL database.
- gene calls will be profiled, using [prodigal](https://github.com/hyattpd/Prodigal).
- Hidden Markov Models (HMMs) will be calculated to utilize multiple default bacterial single-copy core gene collections and identify hits among your genes to those collections using HMMER.
- Lastly, metagenomic reads will be profiled back to the contig database, using bwa and samtools. 

```{bash}
#Below is an example for running one sample.

# Run anvi'o and Kaiju
bash scripts/doKAIJU.sh SRR5916561

# Start profiling for future MAG generation
bash scripts/do_generateMAGs.sh SRR5916561

# convert Kaiju output to usefull file for presence/absence richness
bash scripts/convert_Kaiju.sh SRR5916561
```

## Mining of Biosynthetic Gene Clusters (BGCs)

Both DeepBGC and AntiSmash are effective tools for detecting biosynthetic gene clusters (BGCs). DeepBGC is a deep learning strategy that has shown reduced false positive rates in BGC identification and an improved ability to identify novel BGC classes compared to existing machine-learning tools. On the other hand, AntiSmash is an early tool for BGC discovery that uses a set of curated profile-Hidden Markov Models (pHMMs) to call biosynthetic gene families and a set of rules to identify BGCs [Rios-Martinez et al. 2023](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1011162).

While both tools have their advantages, it ultimately depends on the specific needs of the user. For instance, AntiSmash has been updated to version 7.0, which includes new and improved predictions for detection, regulation, and evolution of BGCs [Blin et al. 2023](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10320115/). Additionally, AntiSmash offers more in-depth analyses for certain BGCs encoding non-ribosomal peptide synthetases (NRPSs), type I and type II polyketide synthases (PKSs), lanthipeptides, lasso peptides, sactipeptides, and thiopeptides [Blin et al., 2021](https://academic.oup.com/nar/article/49/W1/W29/6274535).

DeepBGC employs a data augmentation step to overcome the limited number of known BGCs, which improves its ability to detect BGCs in diverse microbial genomes [Liu et al., 2022](https://www.sciencedirect.com/science/article/pii/S0022283622001772). This means that DeepBGC can identify BGCs in a wider range of microbial species, which is important for discovering novel natural products with potential therapeutic applications and the reason why we focus on [DeepBGC](https://github.com/Merck/deepbgc).

```{bash}
#Below is an example for running one sample.

# Run anvi'o and Kaiju
bash scripts/doDeepBGC.sh SRR5916561
```