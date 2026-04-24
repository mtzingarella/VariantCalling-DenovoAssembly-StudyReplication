#!/bin/bash
#SBATCH --job-name=haplotype_caller
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


module load GATK/4.3.0.0

# set directories
MARKDUP_DIR=../../../results/03_variantcalling/gatk_snp_indel/01_mark_duplicates
RESULTS_DIR=../../../results/03_variantcalling/gatk_snp_indel/02_haplotype_caller
mkdir -p $RESULTS_DIR

GENOME=../../../data/genome/GCF_000750555.1_ASM75055v1_genomic.fna

TMP=../../../data/tmp
mkdir -p $TMP

# sample ID list
SAMPLE_LIST=(SRR25084096 SRR25084097 SRR25084098 SRR25084099 SRR25084100 SRR25084101 SRR25084102 SRR25084103)
SAMPLE=${SAMPLE_LIST[$SLURM_ARRAY_TASK_ID]}



# Run HaplotypeCaller per sample in GVCF mode.
# --sample-ploidy 1: E. coli is a haploid organism; default is 2 (diploid).
# -ERC GVCF: emit a per-sample GVCF for downstream joint genotyping.

gatk HaplotypeCaller \
    -R $GENOME \
    -I $MARKDUP_DIR/${SAMPLE}.markdup.bam \
    -O $RESULTS_DIR/${SAMPLE}.g.vcf.gz \
    -ERC GVCF \
    --sample-ploidy 1 \
    --native-pair-hmm-threads 4 \
    --tmp-dir $TMP
