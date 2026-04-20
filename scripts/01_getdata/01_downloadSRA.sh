#!/bin/bash 
#SBATCH --job-name=fp_getSRA
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


##################################
# Download fastq files from accessionlist of SRA run accessions
##################################

module load sratoolkit/3.0.5

OUTDIR=../../data/raw/fastq
mkdir -p $OUTDIR

ACCLIST=../../data/accessionlist.txt
TMP=/scratch/mzingarella/tmp
mkdir -p $TMP

cat $ACCLIST | while read ACC; do
    echo "Downloading $ACC"
    fasterq-dump $ACC -O $OUTDIR --split-files
done

#################################
# Gunzip compression of all fastq files in OUTDIR
#################################
cd $OUTDIR
for file in *.fastq; do
    echo "Compressing $file"
    gzip $file
done
