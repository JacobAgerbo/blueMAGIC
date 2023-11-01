# Snakemake file for quality control and trimming on paired-end FastQ data
# Load the config file
configfile: "config.yaml"

# Access the configuration parameters
input_dir = config["input_dir"]
output_dir = config["output_dir"]

# Define the input files
fastq_files = [f"{input_dir}/{sample}" for sample in os.listdir(input_dir) if sample.endswith(".fastq.gz")]

# Rule to run FastQC on each FastQ file
rule fastqc:
    input:
        fastq1 = lambda wildcards: f"{input_dir}/{wildcards.sample}_*1.fastq.gz",
        fastq2 = lambda wildcards: f"{input_dir}/{wildcards.sample}_*2.fastq.gz"
    output:
        html = f"{output_dir}/{wildcards.sample}_fastqc.html",
        zip = f"{output_dir}/{wildcards.sample}_fastqc.zip"
    shell:
        """
        fastqc {input.fastq1} {input.fastq2} -o {output_dir}
        """

# Rule to trim the FastQ files using Trimmomatic
rule trimmomatic:
    input:
        fastq1 = lambda wildcards: f"{input_dir}/{wildcards.sample}_*1.fastq.gz",
        fastq2 = lambda wildcards: f"{input_dir}/{wildcards.sample}_*2.fastq.gz"
    output:
        trimmed_fastq1 = f"{output_dir}/{wildcards.sample}_R1_trimmed.fastq.gz",
        trimmed_fastq2 = f"{output_dir}/{wildcards.sample}_R2_trimmed.fastq.gz"
    shell:
        """
        module load trimmomatic
        trimmomatic PE -phred33 {input.fastq1} {input.fastq2} {output.trimmed_fastq1} /dev/null {output.trimmed_fastq2} /dev/null LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
        """

# Rule to run FastQC on the trimmed FastQ files
rule fastqc_trimmed:
    input:
        fastq1 = lambda wildcards: f"{output_dir}/{wildcards.sample}_R1_trimmed.fastq.gz",
        fastq2 = lambda wildcards: f"{output_dir}/{wildcards.sample}_R2_trimmed.fastq.gz"
    output:
        html = f"{output_dir}/{wildcards.sample}_trimmed_fastqc.html",
        zip = f"{output_dir}/{wildcards.sample}_trimmed_fastqc.zip"
    shell:
        """
        fastqc {input.fastq1} {input.fastq2} -o {output_dir}
        """

# Rule to aggregate the FastQC results using MultiQC
rule multiqc:
    input:
        html = expand(f"{output_dir}/{sample}_fastqc.html", sample=[s.split("/")[-1].replace("_R1.fastq.gz", "") for s in fastq_files]) + expand(f"{output_dir}/{sample}_trimmed_fastqc.html", sample=[s.split("/")[-1].replace("_R1_trimmed.fastq.gz", "") for s in fastq_files])
    output:
        html = f"{output_dir}/multiqc_report.html"
    shell:
        """
        multiqc {output_dir} -o {output_dir}
        """

# Define the workflow
rule all:
    input:
        html = f"{output_dir}/multiqc_report.html"

# Rule to classify reads using kraken
rule kraken_classify:
    input:
        fastq1 = lambda wildcards: f"{output_dir}/{wildcards.sample}_R1_trimmed.fastq.gz",
        fastq2 = lambda wildcards: f"{output_dir}/{wildcards.sample}_R2_trimmed.fastq.gz"
    output:
        noEUK_fastq1 = f"{output_dir}/{wildcards.sample}_R1_noEUK.fastq.gz",
        noEUK_fastq2 = f"{output_dir}/{wildcards.sample}_R2_noEUK.fastq.gz"
    shell:
        """
        module load trimmomatic kraken2/2.1.2 pigz/2.6.0
        /projects/mjolnir1/apps/conda/kraken2-2.1.2/bin/kraken2 --db /projects/mjolnir1/data/databases/kraken2/kraken2_standard/20220926/ \
	    --paired --use-names \
	    --threads $SLURM_CPUS_PER_TASK \
	    --output {output_dir}/{wildcards.sample}_12_krk2_500.kraken2 --report {output_dir}/{wildcards.sample}_12_krk2_500.kraken2.report \
	    {input.fastq1}  {input.fastq2}

        # compress reports
        pigz -p $SLURM_CPUS_PER_TASK {output_dir}/{wildcards.sample}_12_krk2_500.kraken2 {output_dir}/{wildcards.sample}_12_krk2_500.kraken2.report
        """

# Rule to extract bacterial classified reads
rule kraken_extract:
    input:
        fastq1 = lambda wildcards: f"{output_dir}/{wildcards.sample}_R1_trimmed.fastq.gz",
        fastq2 = lambda wildcards: f"{output_dir}/{wildcards.sample}_R2_trimmed.fastq.gz"
    output:
        noEUK_fastq1 = f"{output_dir}/{wildcards.sample}_R1_noEUK.fastq.gz",
        noEUK_fastq2 = f"{output_dir}/{wildcards.sample}_R2_noEUK.fastq.gz"
    shell:
        """
        module load trimmomatic kraken2/2.1.2 pigz/2.6.0
        /projects/mjolnir1/apps/bin/extract_kraken_readsBB.py -k {output_dir}/{wildcards.sample}_12_krk2_500.kraken2.gz  \
            -s1 {input.fastq1} \
            -s2 {input.fastq2} \
            -o {output.noEUK_fastq1} \
            -o2 {output.noEUK_fastq2} \
            --fastq-output  --exclude \
            --taxid 2759 --include-children  -r {output_dir}/{wildcards.sample}_12_krk2_500.kraken2.report.gz

            pigz -p $SLURM_CPUS_PER_TASK {output.noEUK_fastq1} {output.noEUK_fastq2}
            echo "This sample is done" > {output_dir}/{wildcards.sample}.done
        """

