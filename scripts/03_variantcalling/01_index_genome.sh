#!/bin/bash 
#SBATCH --job-name=index_genome
#SBATCH --mail-user=vzu25002@uconn.edu
#SBATCH --mail-type=ALL
#SBATCH -o logs/%x_%j.out
#SBATCH -e logs/%x_%j.err
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 5
#SBATCH --mem=50G
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH --export=none


# load indexing software
module load bwa-mem2/2.2.1

#set directories
GENOMEDIR=../../data/genome
RESULTSDIR=../../results/03_variantcalling/01_index_genome
mkdir -p $RESULTSDIR

GENOME=$GENOMEDIR/GCF_000750555.1_ASM75055v1_genomic.fna.gz

# Create index for genome

bwa-mem2 index \
   -p $RESULTSDIR/GCF_000750555 \
   $GENOME
