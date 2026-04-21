#!/bin/bash 
#SBATCH --job-name=post_alignment_QC
#SBATCH --mail-user=vzu25002@uconn.edu
#SBATCH --mail-type=ALL
#SBATCH -o logs/%x_%j.out
#SBATCH -e logs/%x_%j.err
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -c 1
#SBATCH --mem=50G
#SBATCH --qos=general
#SBATCH --partition=general
#SBATCH --cpus-per-task=15
#SBATCH --export=none

hostname
date

# Load QC Software

module load parallel/20180122
module load samtools/1.16.1



ALIGN_DIR=../../results//03_variantcalling/02_align_reads

OUT_DIR=../../results/03_variantcalling/03_post_align_QC
mkdir -p $OUT_DIR

#===========================================================================
#=========== QC 1: SAMSTATS ================================================
#===========================================================================

SAMSTATS_OUT=$OUT_DIR/samstats
mkdir -p $SAMSTATS_OUT

# run samtools stats on each bam file in parallel
for file in $(find $ALIGN_DIR -name "*.bam");
do
    SAM=$(basename $file .bam)
    echo "samtools stats $file >$SAMSTATS_OUT/${SAM}.stats"
done | \
parallel -j 14

# aggregate SN section from all stats files into one table
FILES=($(find $SAMSTATS_OUT -name "*.stats" | sort))

grep "^SN" ${FILES[0]} | cut -f 2 > $SAMSTATS_OUT/SN.txt
for file in ${FILES[@]}
do
    paste $SAMSTATS_OUT/SN.txt <(grep "^SN" $file | cut -f 3) > $SAMSTATS_OUT/SN2.txt && \
    mv $SAMSTATS_OUT/SN2.txt $SAMSTATS_OUT/SN.txt
    echo $file
done

# add header with sample names
cat \
    <(echo ${FILES[@]} | sed "s,$SAMSTATS_OUT/,,g" | sed 's/.stats//g' | sed 's/ /\t/g') \
    $SAMSTATS_OUT/SN.txt \
    > $SAMSTATS_OUT/SN2.txt && \
    mv $SAMSTATS_OUT/SN2.txt $SAMSTATS_OUT/SN.txt

# run multiqc on samstats output
module purge
module load MultiQC/1.15
multiqc -f -o $SAMSTATS_OUT/multiqc $SAMSTATS_OUT


#===========================================================================
#=========== QC 2: COVERAGE ANALYSIS 0.1KB WINDOW===========================
#===========================================================================
#Purging modules between steps because some cause conflicts
module purge
module load bedtools/2.29.0
module load bamtools/2.5.1
module load samtools/1.16.1

COVERAGE_OUT=$OUT_DIR/coverage
mkdir -p $COVERAGE_OUT

GENOME=../../data/genome/GCF_000750555.1_ASM75055v1_genomic.fna

# create faidx genome index file
samtools faidx ${GENOME}
FAI=${GENOME}.fai #created by previous command

# make a "genome" file, required by bedtools makewindows command, set variable for location
GFILE=${COVERAGE_OUT}/GCF_000750555.genome 
cut -f 1-2 $FAI > $GFILE

# make 0.1kb window bed file, set variable for location
WINDOW=${COVERAGE_OUT}/GCF_000750555.0.1kb.windows.bed 
bedtools makewindows -g $GFILE -w 100 > $WINDOW

# make a list of bam files
find $ALIGN_DIR -name "*bam" > $COVERAGE_OUT/bam.list

# calculate per-base coverage as well
bamtools merge -list $COVERAGE_OUT/bam.list | \
bamtools filter -in - -mapQuality ">30" -isDuplicate false -isProperPair true | \
samtools depth -a /dev/stdin | \
awk '{OFS="\t"}{print $1,$2-1,$2,$3'} | \
bedtools map \
-a $WINDOW \
-b stdin \
-c 4 -o mean,median,count \
-g $GFILE | \
bgzip > $COVERAGE_OUT/coverage_0.1kb.bed.gz


#===========================================================================
#=========== QC 2: COVERAGE ANALYSIS 1KB WINDOW=============================
#===========================================================================

WINDOW_1KB=${COVERAGE_OUT}/GCF_000750555.1kb.windows.bed 
bedtools makewindows -g $GFILE -w 1000 > $WINDOW_1KB

bamtools merge -list $COVERAGE_OUT/bam.list | \
bamtools filter -in - -mapQuality ">30" -isDuplicate false -isProperPair true | \
samtools depth -a /dev/stdin | \
awk '{OFS="\t"}{print $1,$2-1,$2,$3'} | \
bedtools map \
-a $WINDOW_1KB \
-b stdin \
-c 4 -o mean,median,count \
-g $GFILE | \
bgzip > $COVERAGE_OUT/coverage_1kb.bed.gz








