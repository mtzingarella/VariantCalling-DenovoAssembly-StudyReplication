#!/bin/bash
#SBATCH --job-name=filter_variants
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
RAW_VCF=../../../results/03_variantcalling/gatk_snp_indel/04_genotype_gvcfs/ecoli_8samples.raw.vcf.gz
RESULTS_DIR=../../../results/03_variantcalling/gatk_snp_indel/05_filter_variants
mkdir -p $RESULTS_DIR

GENOME=../../../data/genome/GCF_000750555.1_ASM75055v1_genomic.fna

TMP=../../../data/tmp
mkdir -p $TMP

#===========================================================================
#=========== STEP 1: SEPARATE SNPs AND INDELS ==============================
#===========================================================================
# SNPs and indels have different error profiles and require different
# filter thresholds, so they must be selected and filtered separately.

gatk SelectVariants \
    -R $GENOME \
    -V $RAW_VCF \
    --select-type-to-include SNP \
    -O $RESULTS_DIR/ecoli_8samples.snps.raw.vcf.gz

gatk SelectVariants \
    -R $GENOME \
    -V $RAW_VCF \
    --select-type-to-include INDEL \
    -O $RESULTS_DIR/ecoli_8samples.indels.raw.vcf.gz

#===========================================================================
#=========== STEP 2: HARD FILTER SNPs ======================================
#===========================================================================
# VQSR is not used: the dataset is too small to train the model and no
# bacterial truth/training VCF exists for this strain.
#
# These thresholds follow the GATK hard-filter guide and should be treated
# as a starting point. Inspect the annotation distributions in the raw VCF
# (e.g., QD, FS, SOR histograms) and tune thresholds before final reporting.
#
# Annotation key:
#   QD   - QualByDepth: variant confidence normalized by depth; low = artifact
#   QUAL - Phred-scaled variant quality; low = low-confidence call
#   SOR  - StrandOddsRatio: strand bias; high = strand-specific artifact
#   FS   - FisherStrand: strand bias (Fisher's exact); high = strand artifact
#   MQ   - RMSMappingQuality: mapping quality of reads; low = poor alignment
#   MQRankSum - difference in MQ between alt and ref reads; large neg = artifact
#   ReadPosRankSum - position of alt allele in read; large neg = end-of-read artifact

gatk VariantFiltration \
    -R $GENOME \
    -V $RESULTS_DIR/ecoli_8samples.snps.raw.vcf.gz \
    --filter-name "QD2"              --filter-expression "QD < 2.0" \
    --filter-name "QUAL30"           --filter-expression "QUAL < 30.0" \
    --filter-name "SOR3"             --filter-expression "SOR > 3.0" \
    --filter-name "FS60"             --filter-expression "FS > 60.0" \
    --filter-name "MQ40"             --filter-expression "MQ < 40.0" \
    --filter-name "MQRankSum-12.5"   --filter-expression "MQRankSum < -12.5" \
    --filter-name "ReadPosRankSum-8" --filter-expression "ReadPosRankSum < -8.0" \
    -O $RESULTS_DIR/ecoli_8samples.snps.filtered.vcf.gz

#===========================================================================
#=========== STEP 3: HARD FILTER INDELS ====================================
#===========================================================================
# Indels use looser thresholds for FS and ReadPosRankSum because indel
# alleles are inherently more strand- and position-biased than SNPs.

gatk VariantFiltration \
    -R $GENOME \
    -V $RESULTS_DIR/ecoli_8samples.indels.raw.vcf.gz \
    --filter-name "QD2"               --filter-expression "QD < 2.0" \
    --filter-name "QUAL30"            --filter-expression "QUAL < 30.0" \
    --filter-name "FS200"             --filter-expression "FS > 200.0" \
    --filter-name "ReadPosRankSum-20" --filter-expression "ReadPosRankSum < -20.0" \
    -O $RESULTS_DIR/ecoli_8samples.indels.filtered.vcf.gz
