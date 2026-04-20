#!/bin/bash 
#SBATCH --job-name=download_genome
#SBATCH --mail-user=vzu25002@uconn.edu
#SBATCH --mail-type=ALL
#SBATCH -o logs/%x_%j.out
#SBATCH -e logs/%x_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=10G
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH --export=none


hostname
date

# Genome: https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000750555.1/

# 2014 Complete Assembly at 100x coverage. Annotation from 2025


##################################
# Download Genome From NCBI
##################################

OUTDIR=../../data/genome
mkdir -p $OUTDIR
cd $OUTDIR

#Genome fasta
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/750/555/GCF_000750555.1_ASM75055v1/GCF_000750555.1_ASM75055v1_genomic.fna.gz

#Genome annotation (gff)
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/750/555/GCF_000750555.1_ASM75055v1/GCF_000750555.1_ASM75055v1_genomic.gff.gz


zcat $OUTDIR/GCF_000750555.1_ASM75055v1_genomic.fna.gz > $OUTDIR/GCF_000750555.1_ASM75055v1_genomic.fna
zcat $OUTDIR/GCF_000750555.1_ASM75055v1_genomic.gff.gz > $OUTDIR/GCF_000750555.1_ASM75055v1_genomic.gff
