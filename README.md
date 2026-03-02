
# VariantCalling-DenovoAssembly-StudyReplication

## Project overview

This repository contains a replication and extension of the analysis from:

> Paterson JR, Wadsworth JM, Hu P, Sharples GJ.
> **A critical role for iron and zinc homeostatic systems in the evolutionary adaptation of *Escherichia coli* to metal restriction.** *Microbial Genomics* 9:001153 (2023).


This was completed as a final project for the University of Connecticut's ISG5312 Genomic Data Analysis in Practice course.


The goal of this project is to reprocess the raw data and to organize the analysis in a reproducible way. 

## Directory structure

Current top‑level layout:

```text
VariantCalling-DenovoAssembly-StudyReplication/
├── data/
│   ├── genome/
│   ├── raw/
│   └── trimmed/
├── results/
│   ├── 02_qc_trimming/
│   ├── 03_variantcalling/
│   ├── 04_denovoassemblies/
│   └── 05_downstream/
└── scripts/
    ├── 01_getdata/
    ├── 02_qc_trimming/
    ├── 03_variantcalling/
    ├── 04_denovoassemblies/
    └── 05_downstream/
```

Below is the intended role of each directory.

### `data/`

All input data required for the analysis.

- `data/genome/`
    - Reference genome for *E. coli* BW25113 (e.g., CP009273.1) and any associated index/annotation files used for mapping and variant annotation.[web:222]
- `data/raw/`
    - Raw FASTQ files downloaded from SRA (ancestor, EDTA‑evolved lines, DTPMP‑evolved lines, untreated control).
- `data/trimmed/`
    - Adapter‑ and quality‑trimmed reads produced by the QC/trimming step.
    - These are the inputs to mapping, variant calling, and optional assemblies.


### `results/`

This directory will store all outputs produced by the analysis, separated from the raw input data.

- `results/02_qc_trimming/`
    - Quality‑control reports for raw and trimmed reads (e.g., FastQC/MultiQC outputs).
    - Any summary tables/plots describing read quality and trimming outcomes.
- `results/03_variantcalling/`
    - Outputs from the reference‑based variant‑calling pipeline, such as:
        - Mapped and processed BAM files.
        - Raw and filtered VCFs.
        - Annotated variant tables (e.g., SnpEff output) ready for downstream analysis.
- `results/04_denovoassemblies/`
    - Outputs from optional de novo assemblies for each isolate, including:
        - Assembly files (contigs/scaffolds).
        - Assembly QC reports (e.g., QUAST).
        - Annotation files (e.g., Prokka output).
- `results/05_downstream/`
    - Outputs from downstream interpretation, for example:
        - Tables summarizing mutations per sample and per pathway (yeiR, fepA/entD, cadC, other).
        - Comparisons between ancestor vs each evolved line vs control.
        - Final figures (mutation maps, pathway barplots, promoter alignments, etc.).


### `scripts/`

All code for running the analysis is organized by phase, following the same high‑level workflow as the flowchart.

- `scripts/01_getdata/`
    - Code to download data from public repositories (e.g., SRA reads, reference genome) into `data/raw/` and `data/genome/`.
- `scripts/02_qc_trimming/`
    - Code for read‑level QC on raw data.
    - Code for adapter/quality trimming and post‑trim QC.
    - Writes trimmed FASTQs to `data/trimmed/` and QC outputs to `results/02_qc_trimming/`.
- `scripts/03_variantcalling/`
    - Code for mapping trimmed reads to the *E. coli* BW25113 reference genome and generating BAM files.
    - Code for variant calling, filtering, and annotation.
    - Writes outputs into `results/03_variantcalling/`.
- `scripts/04_denovoassemblies/`
    - Code for optional de novo assemblies of each isolate and their QC/annotation.
    - Writes outputs into `results/04_denovoassemblies/`.
    - This path is secondary to the reference‑based variant calling but useful to cross‑check key regions (e.g., promoters of *yeiR* and *fepA/entD*).[web:222]
- `scripts/05_downstream/`
    - Code for comparing variant sets across conditions (EDTA vs DTPMP vs control).
    - Code for classifying mutations by metal‑homeostasis pathway and generating summary tables/figures.
    - Writes outputs into `results/05_downstream/`.


***

## Workflow summary

At a high level, the analysis proceeds through these phases:

1. **Data acquisition**
    - Download WGS reads for ancestor, evolved lines, and control.
    - Download the *E. coli* BW25113 reference genome.
2. **QC and trimming**
    - Run initial QC on raw reads.
    - Perform adapter and quality trimming.
    - Re‑run QC on trimmed reads and summarize.
3. **Variant calling (reference‑based)**
    - Map trimmed reads to the BW25113 reference.
    - Process alignment files and call variants.
    - Filter and annotate variants to obtain a high‑confidence set of mutations per sample.
4. **Optional de novo assembly**
    - Assemble each sample de novo.
    - Assess assembly quality and annotate.
    - Use assemblies as a secondary resource to validate key mutation calls.
5. **Downstream interpretation**
    - Compare variants across samples (ancestor vs each evolved line vs control).
    - Classify mutations into metal‑related pathways (Zn metallochaperone, Fe siderophore uptake, acid tolerance, other).
    - Generate figures and summary outputs.


<img width="1075" height="3600" alt="image" src="https://github.com/user-attachments/assets/014282a3-b63e-414b-8fa1-15b6969dd9a4" />

