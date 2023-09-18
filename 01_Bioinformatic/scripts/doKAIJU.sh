#!/bin/sh
#do Kaiju and anvio
module load kaiju anvio bwa samtools

READS="/projects/mjolnir1/people/bfg522/04_Marine_Mining/01_No_EUK"
CONTIGS="/projects/mjolnir1/people/bfg522/04_Marine_Mining/02_Assemblies"
OUT="/projects/mjolnir1/people/bfg522/04_Marine_Mining/06_MAGs"
mkdir $OUT/$1/
echo "starting genome-resolved metagenomics on: "$1""
anvi-script-reformat-fasta $CONTIGS/$1/final.contigs.fa -o $CONTIGS/$1/contigs-fixed.fa -l 1000 --simplify-names
anvi-gen-contigs-database -f $CONTIGS/$1/contigs-fixed.fa -o $OUT/$1/CONTIGS.db -n 'CONTIG DB for marine metagenomes'
anvi-get-sequences-for-gene-calls -c $OUT/$1/CONTIGS.db -o $OUT/$1/gene_calls.fa


echo "starting kaiju: "$1""
kaiju -t /projects/mjolnir1/data/databases/kaiju/2021-11-05/nodes.dmp \
      -f /projects/mjolnir1/data/databases/kaiju/2021-11-05/nr_euk/kaiju_db_nr_euk.fmi \
      -i $OUT/$1/gene_calls.fa \
      -o $OUT/$1/gene_calls_nr.out \
      -z $SLURM_CPUS_PER_TASK \
      -v

#
kaiju-addTaxonNames -t /projects/mjolnir1/data/databases/kaiju/2021-11-05/nodes.dmp \
              -n /projects/mjolnir1/data/databases/kaiju/2021-11-05/names.dmp \
              -i $OUT/$1/gene_calls_nr.out \
              -o $OUT/$1/gene_calls_nr.names \
              -r superkingdom,phylum,order,class,family,genus,species
#
echo "kaiju finished on: "$1""