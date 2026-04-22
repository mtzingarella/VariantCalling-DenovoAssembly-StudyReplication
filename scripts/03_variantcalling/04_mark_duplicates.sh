#!/bin/bash
#SBATCH --job-name=mark_duplicates
#SBATCH --mail-user=vzu25002@uconn.edu
#SBATCH --mail-type=ALL
#SBATCH -o logs/%x_%j.out
#SBATCH -e logs/%x_%j.err
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 4
#SBATCH --mem=20G
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH --array=[0-7]
#SBATCH --export=none

hostname
date

# Note: samblaster marked duplicates during alignment; GATK MarkDuplicates is run
# here to re-flag duplicates in GATK-compatible format and produce per-sample
# duplicate metrics. It also enables GATK's NotDuplicateReadFilter to work
# correctly during variant calling.

module load GATK/4.3.0.0

# set directories
ALIGN_DIR=../../results/03_variantcalling/02_align_reads
RESULTS_DIR=../../results/03_variantcalling/04_mark_duplicates
mkdir -p $RESULTS_DIR

GENOME=../../data/genome/GCF_000750555.1_ASM75055v1_genomic.fna
DICT=${GENOME%.fna}.dict

TMP=../../data/tmp
mkdir -p $TMP

# create the sequence dictionary if it does not already exist
if [ ! -f $DICT ]; then
    gatk CreateSequenceDictionary \
        -R $GENOME \
        -O $DICT
fi

# sample ID list
SAMPLE_LIST=(SRR25084096 SRR25084097 SRR25084098 SRR25084099 SRR25084100 SRR25084101 SRR25084102 SRR25084103)
SAMPLE=${SAMPLE_LIST[$SLURM_ARRAY_TASK_ID]}

# mark duplicates and emit per-sample metrics file
gatk MarkDuplicates \
    -I $ALIGN_DIR/${SAMPLE}.bam \
    -O $RESULTS_DIR/${SAMPLE}.markdup.bam \
    -M $RESULTS_DIR/${SAMPLE}.dup_metrics.txt \
    --TMP_DIR $TMP

# index the output BAM
gatk BuildBamIndex \
    -I $RESULTS_DIR/${SAMPLE}.markdup.bam
