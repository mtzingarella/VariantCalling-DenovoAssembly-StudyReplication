#!/bin/bash 
#SBATCH --job-name=fp_rawmultiQC
#SBATCH --mail-user=vzu25002@uconn.edu
#SBATCH --mail-type=ALL
#SBATCH -o logs/%x_%j.out
#SBATCH -e logs/%x_%j.err
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 3
#SBATCH --mem=10G
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH --export=none

hostname
date

INDIR=../../results/02_qc_trimming/raw_fastqc
OUTDIR=../../results/02_qc_trimming/multiqc/raw
mkdir -p $OUTDIR

module load MultiQC/1.15

# Run multiqc on all fastqc reports in the INDIR
multiqc -f -o $OUTDIR $INDIR
