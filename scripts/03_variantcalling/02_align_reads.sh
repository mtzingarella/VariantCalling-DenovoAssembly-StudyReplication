#!/bin/bash 
#SBATCH --job-name=align_reads
#SBATCH --mail-user=vzu25002@uconn.edu
#SBATCH --mail-type=ALL
#SBATCH -o logs/%x_%j.out
#SBATCH -e logs/%x_%j.err
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 6
#SBATCH --mem=50G
#SBATCH --qos=general
#SBATCH --partition=xeon
#SBATCH --array=[0-7]
#SBATCH --export=none


hostname
date

# load required software
module load samtools/1.20
module load samblaster/0.1.24
module load bwa-mem2/2.2.1

SAMPLE_DIRECTORY=../../data/trimmed_strict

RESULTS_DIRECTORY=../../results/03_variantcalling/02_align_reads

mkdir -p $RESULTS_DIRECTORY

INDEX=../../results/03_variantcalling/01_index_genome/GCF_000750555



# sample ID list
SAMPLE_LIST=(SRR25084096 SRR25084097 SRR25084098 SRR25084099 SRR25084100 SRR25084101 SRR25084102 SRR25084103)

# extract one sample ID
SAMPLE=${SAMPLE_LIST[$SLURM_ARRAY_TASK_ID]}

# create read group string
RG=$(echo \@RG\\tID:$SAMPLE\\tSM:$SAMPLE)

# execute the alignment pipe
bwa-mem2 mem -t 5 -R ${RG} ${INDEX} \
    ${SAMPLE_DIRECTORY}/${SAMPLE}_1.trimmed.fastq.gz \
    ${SAMPLE_DIRECTORY}/${SAMPLE}_2.trimmed.fastq.gz | \
    samblaster | \
    samtools view -S -h -u - | \
    samtools sort -T ${RESULTS_DIRECTORY}/${SAMPLE}.temp -O BAM > ${RESULTS_DIRECTORY}/${SAMPLE}.bam

# index alignment file
samtools index ${RESULTS_DIRECTORY}/${SAMPLE}.bam


