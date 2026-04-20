#!/bin/bash 
#SBATCH --job-name=fp_rawQC
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


RAWDATADIR=../../data/raw/fastq
OUTDIR=../../results/02_qc_trimming/raw_fastqc
mkdir -p $OUTDIR

module load fastqc/0.12.1


# Run fastqc on all .fastq.gz files in the RAWDATADIR

fastqc $RAWDATADIR/*.fastq.gz -o $OUTDIR -t 3


