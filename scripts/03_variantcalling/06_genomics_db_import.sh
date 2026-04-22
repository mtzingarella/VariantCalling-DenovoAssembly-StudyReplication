#!/bin/bash
#SBATCH --job-name=genomics_db_import
#SBATCH --mail-user=vzu25002@uconn.edu
#SBATCH --mail-type=ALL
#SBATCH -o logs/%x_%j.out
#SBATCH -e logs/%x_%j.err
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 4
#SBATCH --mem=50G
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH --export=none

hostname
date


module load GATK/4.3.0.0

# set directories
GVCF_DIR=../../results/03_variantcalling/05_haplotype_caller
RESULTS_DIR=../../results/03_variantcalling/06_genomics_db_import
mkdir -p $RESULTS_DIR

GENOME=../../data/genome/GCF_000750555.1_ASM75055v1_genomic.fna
FAI=${GENOME}.fai

TMP=../../data/tmp
mkdir -p $TMP

# resolve GVCF directory to an absolute path, required by GenomicsDBImport
GVCF_ABS=$(cd $GVCF_DIR && pwd)

# sample ID list
SAMPLE_LIST=(SRR25084096 SRR25084097 SRR25084098 SRR25084099 SRR25084100 SRR25084101 SRR25084102 SRR25084103)

# build the two-column tab-separated sample map: sample_name <tab> gvcf_path
# GenomicsDBImport requires absolute paths in the sample map
SAMPLE_MAP=$RESULTS_DIR/cohort.sample_map
> $SAMPLE_MAP
for SAMPLE in ${SAMPLE_LIST[@]}; do
    echo -e "${SAMPLE}\t${GVCF_ABS}/${SAMPLE}.g.vcf.gz" >> $SAMPLE_MAP
done

# build a contig list from the reference index
# GenomicsDBImport requires at least one interval for a new workspace
CONTIG_LIST=$RESULTS_DIR/all_contigs.list
cut -f1 $FAI > $CONTIG_LIST

# import all 8 per-sample GVCFs into a GenomicsDB workspace for joint genotyping.
# Note: the workspace directory (ecoli_gdb) must NOT already exist when this runs.
# To re-run this script, first remove the existing workspace:
#   rm -rf $RESULTS_DIR/ecoli_gdb
gatk GenomicsDBImport \
    --sample-name-map $SAMPLE_MAP \
    --genomicsdb-workspace-path $RESULTS_DIR/ecoli_gdb \
    -L $CONTIG_LIST \
    --reader-threads 4 \
    --tmp-dir $TMP
