#!/bin/bash 
#SBATCH --job-name=fp_trimmomatic
#SBATCH --mail-user=vzu25002@uconn.edu
#SBATCH --mail-type=ALL
#SBATCH -o logs/%x_%j.out
#SBATCH -e logs/%x_%j.err
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 1
#SBATCH --mem=15G
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH --export=none
#SBATCH --array=[1-8]%4

hostname
date

INDIR=../../data/raw/fastq
OUTDIR=../../results/02_qc_trimming/03_trimmomatic
mkdir -p $OUTDIR

module load Trimmomatic/0.39


# adapters to trim out
ADAPTERS=/isg/shared/apps/Trimmomatic/0.39/adapters/TruSeq3-PE-2.fa

# accession list
ACCLIST=../../data/accessionlist.txt

SAMPLE=$( sed -n ${SLURM_ARRAY_TASK_ID}p ${ACCLIST} )



java -jar ${Trimmomatic} PE -threads 4 \
    ${INDIR}/${SAMPLE}_1.fastq.gz ${INDIR}/${SAMPLE}_2.fastq.gz \
    ${OUTDIR}/${SAMPLE}_1.trimmed.fastq.gz ${OUTDIR}/${SAMPLE}_1.unpaired.fastq.gz \
    ${OUTDIR}/${SAMPLE}_2.trimmed.fastq.gz ${OUTDIR}/${SAMPLE}_2.unpaired.fastq.gz \
    ILLUMINACLIP:${ADAPTERS}:2:30:10 \
    SLIDINGWINDOW:4:15 MINLEN:50







