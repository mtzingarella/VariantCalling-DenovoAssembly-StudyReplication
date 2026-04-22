#!/bin/bash
#SBATCH --job-name=genotype_gvcfs
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
#SBATCH --export=none

hostname
date


module load GATK/4.3.0.0

# set directories
GDB_DIR=../../results/03_variantcalling/06_genomics_db_import
RESULTS_DIR=../../results/03_variantcalling/07_genotype_gvcfs
mkdir -p $RESULTS_DIR

GENOME=../../data/genome/GCF_000750555.1_ASM75055v1_genomic.fna

TMP=../../data/tmp
mkdir -p $TMP

# resolve GenomicsDB path to absolute (gendb:// requires an absolute path)
GDB_ABS=$(cd $GDB_DIR && pwd)

# joint genotype all 8 samples from the GenomicsDB workspace into a single
# multi-sample raw VCF with one genotype column per sample
gatk GenotypeGVCFs \
    -R $GENOME \
    -V gendb://${GDB_ABS}/ecoli_gdb \
    -O $RESULTS_DIR/ecoli_8samples.raw.vcf.gz \
    --tmp-dir $TMP
